require 'English'
require 'fileutils'
require 'open3'

namespace :gitswarm do
  desc 'Combine the docs from GitLab and the PerforceSwarm engine into the specified folder'
  task :render_md_docs do
    # throw away the rake task name, and second one if its a -- to pass it to argparse
    ARGV.shift
    ARGV.shift if ARGV[0] == '--'

    output_dir = ARGV[0]
    fail 'You must specify an output directory' unless output_dir
    output_dir = output_dir.gsub(%r{/$}, '')

    PerforceSwarm::Help.render do |content, file|
      output_file = File.join(output_dir, file)
      FileUtils.mkdir_p(File.dirname(output_file))
      File.write(output_file, content)
    end
  end

  # Note the general concept of using pandoc, the template and the styles are all taken from the GitLab repo:
  # git@gitlab.com:gitlab-com/doc-gitlab-com.git
  # Its likely worth glancing at their logic occasionally to see if any updates are warranted.
  desc 'Render the combined GitSwarm/GitLab docs to HTML output in the specified folder'
  task :render_html_docs do
    # throw away the rake task name, and second one if its a -- to pass it to argparse
    ARGV.shift
    ARGV.shift if ARGV[0] == '--'

    output_dir = ARGV[0]
    fail 'You must specify an output directory' unless output_dir
    output_dir = output_dir.gsub(%r{/$}, '')

    fail 'It does not appear pandoc is installed; kindly install it.' unless `pandoc -v` && $CHILD_STATUS.success?

    template_path = File.join(__dir__, 'docs', 'template.html')
    PerforceSwarm::Help.render do |content, file|
      output_file = File.join(output_dir, file)
      FileUtils.mkdir_p(File.dirname(output_file))

      # md files need to be converted to HTML. non-md files just flow through as-is
      if file.end_with?('.md')
        # Calculate how deep this particular file is and then a relative root path
        depth     = file.gsub(%r{^/|/$}, '').count('/')
        root_path = depth > 0 ? '../' * depth : './'
        root_path = root_path.gsub(%r{/$}, '')

        # de-link absolute links, since they don't play nice with our static docs
        content.gsub!(%r{\[([^\]]+)\]\(/[^)]+\)}, '\1') unless file.end_with?('markdown.md')

        # Some files already have a table of contents, don't add another table of contents to them.
        toc = file.end_with?('README.md') || file.end_with?('markdown.md') ? nil : '--toc'

        # Calculate the required flags for pandoc
        pandoc  = "pandoc #{toc} --template #{template_path} --from markdown_github-hard_line_breaks "
        pandoc += "-V #{'version=' + PerforceSwarm::VERSION} -V #{'edition=' + (PerforceSwarm.ee? ? '-EE' : '')} "
        pandoc += "-V #{'root-path=' + root_path}"

        content, status = Open3.capture2e(pandoc, stdin_data: content)
        fail content unless status.success?

        content.gsub!(/href="(\S*)"/) do |result|   # Fetch all links in the HTML Document
          if /http/.match(result).nil?              # Check if link is internal
            result.gsub!(/\.md/, '.html')           # Replace the extension if link is internal
          end
          result
        end

        # rename the output from .md to .html. for the root README rename it to index.html
        output_file = output_file.gsub(/\.md$/, '.html').gsub("#{output_dir}/README.html", "#{output_dir}/index.html")
      end

      File.write(output_file, content)
    end

    FileUtils.cp_r(File.join(__dir__, 'docs', 'stylesheets'), File.join(output_dir, 'stylesheets'))
  end
end
