xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "ecfs.link"
    xml.description "Feed for #{query}"
    xml.link "https://ecfs.link"

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