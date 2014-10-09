<?xml version="1.0" encoding="UTF-8"?>
<!--
    extract a single broadcast (episode)

    $ xsltproc - -html br-episode.xslt http://www.br.de/radio/bayern2/programmkalender/sendung611984.html

    http://www.w3.org/TR/xslt
-->
<xsl:stylesheet
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:tl="http://purl.org/NET/c4dm/timeline.owl#"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:date="http://exslt.org/dates-and-times"
    exclude-result-prefixes="xsl"
    version="1.0">
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <rdf:RDF xml:base="http://www.br.de">
      <xsl:apply-templates select="html/body/div/div/div[@id='content']/div[contains(@class,' bcast ')]/div[@class='detail_inlay']" />
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="div">
    <rdf:Description rdf:about="">
      <xsl:for-each select="/html/head/meta[@http-equiv='Language']/@content">
        <dcterms:language rdf:datatype="http://purl.org/dc/terms/ISO639-2"><xsl:value-of select="."/></dcterms:language>
      </xsl:for-each>
      <xsl:for-each select="/html/head/meta[@name='author']/@content">
        <dcterms:author rdf:datatype="http://www.w3.org/2001/XMLSchema#string"><xsl:value-of select="."/></dcterms:author>
      </xsl:for-each>
      <xsl:for-each select="/html/head/meta[@name='copyright']/@content">
        <dcterms:copyright xml:lang="{/html/head/meta[@http-equiv='Language']/@content}"><xsl:value-of select="."/></dcterms:copyright>
      </xsl:for-each>
      <dcterms:creator rdf:datatype="http://www.w3.org/2001/XMLSchema#string" />
      <dcterms:publisher rdf:datatype="http://www.w3.org/2001/XMLSchema#string" />
      <xsl:for-each select="div[@class='bcast_head']/div[@class='detail_picture_256']/div[@class='detail_picture_inlay']/span/img/@src">
        <dcterms:image rdf:resource="{.}"/>
      </xsl:for-each>
      <xsl:for-each select="h1">
        <dcterms:title xml:lang="{/html/head/meta[@http-equiv='Language']/@content}"><xsl:value-of select="normalize-space(text())"/></dcterms:title>
        <xsl:for-each select="span[@class='bcast_subtitle']">
          <dcterms:titleEpisode xml:lang="{/html/head/meta[@http-equiv='Language']/@content}"><xsl:value-of select="normalize-space(text())"/></dcterms:titleEpisode>
        </xsl:for-each>
        <xsl:for-each select="span[@class='bcast_overline']">
          <dcterms:titleSeries xml:lang="{/html/head/meta[@http-equiv='Language']/@content}"><xsl:value-of select="normalize-space(text())"/></dcterms:titleSeries>
        </xsl:for-each>
      </xsl:for-each>
      <xsl:for-each select="div[@class='bcast_head']/div[@class='bcast_info']/p[@class='bcast_date']">
        <dcterms:extent>
          <tl:Interval>
            <xsl:comment> TODO: Timezone </xsl:comment>
            <xsl:variable name="part0" select="normalize-space(substring-before(substring-after(.,','),'Uhr'))"/>
            <xsl:variable name="date0" select="substring-before($part0,' ')"/>
            <xsl:variable name="time0" select="substring-after($part0,' ')"/>
            <xsl:variable name="year" select="substring-after(substring-after($date0,'.'),'.')"/>
            <xsl:variable name="month" select="substring-before(substring-after($date0,'.'),'.')"/>
            <xsl:variable name="day" select="substring-before($date0,'.')"/>
            <xsl:variable name="date">
              <xsl:value-of select="$year"/>-<xsl:value-of select="$month"/>-<xsl:value-of select="$day"/>
            </xsl:variable>
            <xsl:variable name="t_start" select="normalize-space(substring-before($time0,'bis'))"/>
            <xsl:variable name="t_stop" select="normalize-space(substring-after($time0,'bis'))"/>
            <xsl:comment> time demo (http://www.exslt.org/date/functions/time/index.html):
              raw: <xsl:value-of select="concat(concat(concat($date,'T'),$t_start),':00')"/>
              date: <xsl:value-of select="date:date(concat(concat(concat($date,'T'),$t_start),':00'))"/>
              time: <xsl:value-of select="date:time(concat(concat(concat($date,'T'),$t_start),':00'))"/>
            </xsl:comment>
            <tl:at rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="$date"/>T<xsl:value-of select="$t_start"/>:00</tl:at>
            <xsl:comment>TODO: add one day in case stop &lt; start</xsl:comment>
            <tl:end rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="$date"/>T<xsl:value-of select="$t_stop"/>:00</tl:end>
          </tl:Interval>
        </dcterms:extent>
      </xsl:for-each>
      <dcterms:description xml:lang="{/html/head/meta[@http-equiv='Language']/@content}">
        <xsl:for-each select="p">
          <xsl:for-each select="*|text()">
          	<xsl:choose>
          	  <xsl:when test="name() = 'br'"><xsl:text>&#10;<!-- linefeed --></xsl:text></xsl:when>
          	  <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
          	</xsl:choose>
          </xsl:for-each>
          <xsl:text>&#10;&#10;<!-- double linefeed --></xsl:text>
        </xsl:for-each>
      </dcterms:description>
    </rdf:Description>

    <xsl:comment> TODO dcterms:identifier,dcterms:source,dcterms:isPartOf,dcterms:relation
      <dcterms:identifier rdf:datatype="http://www.w3.org/2001/XMLSchema#string">b2/2013/08/22/1005 Sommernotizbuch</dcterms:identifier>
      <dcterms:source rdf:resource="http://www.br.de/radio/bayern2/programmkalender/sendung611984.html"/>
      <dcterms:isPartOf rdf:resource="http://rec.domus.mro.name/stations/b2/"/>
      <dcterms:relation rdf:resource="http://rec.domus.mro.name/enclosures/b2/2013/08/22/1005 Sommernotizbuch.mp3"/>
    </xsl:comment>      
  </xsl:template>
</xsl:stylesheet>