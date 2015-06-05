require Rails.root.join('app', 'helpers', 'appearances_helper')

module AppearancesHelper
  BRAND_TITLE_VALUE = 'GitSwarm'

  def brand_title
    return BRAND_TITLE_VALUE
  end
end
