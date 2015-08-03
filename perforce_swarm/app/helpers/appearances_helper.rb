require Rails.root.join('app', 'helpers', 'appearances_helper')

module AppearancesHelper
  BRAND_TITLE_VALUE = 'GitSwarm'

  def brand_title
    return brand_item.title if PerforceSwarm.ee? && brand_item

    BRAND_TITLE_VALUE
  end

  def brand_header_logo
    if PerforceSwarm.ee? && brand_item && brand_item.light_logo?
      image_tag brand_item.light_logo, class: 'brand-logo'
    else
      content_tag :div, nil, class: 'brand-logo'
    end
  end
end
