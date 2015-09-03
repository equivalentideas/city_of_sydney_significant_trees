require 'scraperwiki'
require 'mechanize'

def scrape_page(page)
  page.search('.location').each do |item|
    if item.text.include?('No species found')
      types_of_trees = 'No species found'
    else
      types_of_trees = item.at('.term-list').search(:li).map(&:text).join(', ')
    end

    location = {
      name: item.at(:h2).text,
      time_planted: item.at(:strong).next.text.strip,
      types_of_trees: types_of_trees,
      url: @root + item.at(:a)[:href]
    }

    p location

    ScraperWiki.save_sqlite([:name], location)
  end
end

def scrape_then_click_next(page)
  scrape_page(page)
  if !page.link_with(text: 'Next page').nil?
    page =  @agent.click(page.link_with(text: 'Next page')) 
    scrape_then_click_next(page)
  else
    p "That’s all folks"
  end
end

@agent = Mechanize.new
@root = 'http://trees.cityofsydney.nsw.gov.au'
page = @agent.get(@root + '/location/')

scrape_then_click_next(page)
