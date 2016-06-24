require 'active_support'

# Extend Active Support Concern to support 'prepends' for the ClassMethods (before_filter, after_filter, etc)
# This fix was supplied by https://github.com/dockyard/easy_auth/blob/master/lib/easy_auth/active_support/concern.rb
module ActiveSupport::Concern
  # This is the append_features from rails, but updated to skip skip prepends
  # base is: https://github.com/rails/rails/blob/4-1-stable/activesupport/lib/active_support/concern.rb
  def append_features(base)
    if base.instance_variable_defined?('@_dependencies')
      # This line updated to track whether the method to use when loading
      base.instance_variable_get('@_dependencies') << { method: :include, module: self }
      return false
    else
      return false if base < self
      # This line updated to use the appropriate method, defaulting back to the original :include
      @_dependencies.each do |dep|
        dep.instance_of?(Hash) ? base.send(dep[:method], dep[:module]) : base.send(:include, dep)
      end
      super
      base.extend const_get('ClassMethods') if const_defined?('ClassMethods')
      base.class_eval(&@_included_block) if instance_variable_defined?('@_included_block')
    end
  end

  # This is an addition to support prepending the concern into other classes, it is a copy
  # of append_features but uses the :prepend method and tracks the _prepended_block
  def prepend_features(base)
    if base.instance_variable_defined?('@_dependencies')
      base.instance_variable_get('@_dependencies').unshift(method: :prepend, module: self)
      return false
    else
      return false if base < self
      super
      base.singleton_class.send(:prepend, const_get('ClassMethods')) if const_defined?('ClassMethods')
      @_dependencies.each do |dep|
        dep.instance_of?(Hash) ? base.send(dep[:method], dep[:module]) : base.send(:prepend, dep)
      end
      base.class_eval(&@_prepended_block) if instance_variable_defined?('@_prepended_block')
    end
  end

  # This is an addition to support tracking prepend calls
  def prepended(base = nil, &block)
    if base.nil?
      raise MultipleIncludedBlocks if instance_variable_defined?('@_prepended_block')

      @_prepended_block = block
    else
      super
    end
  end
end
