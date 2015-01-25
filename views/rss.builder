xml.instruct! :xml, version: '1.0'
xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    feed_url = "https://ecfs.link/search.rss?q=#{query}"
    xml.title "ecfs.link"
    xml.description "Feed for #{query}"
    xml.link feed_url
    xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => feed_url

    results.each do |result|
      xml.item do
        xml.title result.citation
        xml.link result.fcc_url
        xml.description result.citation
        xml.pubDate Time.parse(result.date_received.to_s).rfc822()
        xml.guid result.fcc_url
      end
    end
    
  end
end