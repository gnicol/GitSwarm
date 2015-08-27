# Applies a syntax highlighting color scheme CSS class to any element with the
# `js-syntax-highlight` class
#
# ### Example Markup
#
#   <div class="js-syntax-highlight"></div>
#
$(document).on 'ready page:load', ->
  $('.js-syntax-highlight').addClass(gon.user_color_scheme)
