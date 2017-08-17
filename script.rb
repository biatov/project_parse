require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'csv'
require 'open_uri_redirections'

start_url = "http://www.petsonic.com/es/perros/snacks-y-huesos-perro"

def new_open link
  Nokogiri::HTML(open(link,
                      :allow_redirections => :safe, 'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.9 Safari/536.5'))
end

def process (url, filename)
  doc = new_open url
  all = /\d+/.match(doc.xpath("//small[@class='heading-counter']/text()").to_s).to_s
  count_per_page = doc.xpath("//select[@id='nb_item']/option[@selected='selected']/@value").to_s
  pages = (all.to_f/count_per_page.to_f).ceil

  CSV.open("#{filename}.csv", 'w') do |row|
    row << ["Title", "Price", "Image"]
    for page in (1..pages) do
      doc = new_open  "#{url}?p=#{page}"
      product_url = doc.xpath("//a[@class='product-name']/@href")
      for each in product_url do
        doc2 = new_open each
        name = doc2.xpath('//h1/text()')
        peso = doc2.xpath('//div[@class="attribute_list"]/ul[@class="attribute_labels_lists"]').xpath('.//span[@class="attribute_name"]/text()')
        price = doc2.xpath('//div[@class="attribute_list"]/ul[@class="attribute_labels_lists"]').xpath('.//span[@class="attribute_price"]/text()')
        image = doc2.xpath('//ul[@id="thumbs_list_frame"]').xpath('.//a/img/@src')
        peso.each_with_index do |item, index|
          row << ["#{name} #{item}".strip, "#{price[index]}".strip, "#{image[index]}".strip] if price[index] and image[index]
        end
      end
     end
  end
end

process start_url, 'solution'
