require Rails.root.join('app', 'helpers', 'page_layout_helper')

module PageLayoutHelper
  def page_title(*titles)
    @page_title ||= []

    @page_title.push(*titles.compact) if titles.any?

    @page_title.join(' | ').gsub!(/GitLab/, 'GitSwarm')
  end
end
