<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:ghost="http://docbook.org/ns/docbook/ephemeral"
		xmlns:db="http://docbook.org/ns/docbook"
		exclude-result-prefixes="h f m fn db t ghost"
		version="2.0">

  <xsl:import href="dist/xslt/base/html/docbook.xsl"/>
  <xsl:include href="dist/xslt/base/html/chunktemp.xsl"/>
  <xsl:param name="use.id.as.filename" select="'1'"/>
  <!-- <xsl:param name="html.ext" select="'.jspx'"/> -->
  <xsl:param name="linenumbering" as="element()*">
  <!--  <ln xmlns="http://docbook.org/ns/docbook" path="literallayout" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>-->
    <!-- <ln xmlns="http://docbook.org/ns/docbook"  -->
    <!-- 	path="programlisting"  -->
    <!-- 	everyNth="2"  -->
    <!-- 	width="3"  -->
    <!-- 	separator=" "  -->
    <!-- 	padchar=" "  -->
    <!-- 	minlines="3"/> -->
    <!--<ln xmlns="http://docbook.org/ns/docbook" path="programlistingco" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
    <ln xmlns="http://docbook.org/ns/docbook" path="screen" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
    <ln xmlns="http://docbook.org/ns/docbook" path="synopsis" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
    <ln xmlns="http://docbook.org/ns/docbook" path="address" everyNth="0"/>-->
    <ln xmlns="http://docbook.org/ns/docbook" path="epigraph/literallayout" everyNth="0"/>
  </xsl:param>

  <xsl:param name="base.dir" select="'target/docbkx/xhtml/example/'"/>

  <xsl:param name="generate.toc" as="element()*">
    <tocparam xmlns="http://docbook.org/ns/docbook" path="appendix" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="article/appendix" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="article" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="book" toc="0" title="1" figure="1" table="1" example="1" equation="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="chapter" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="part" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="preface" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="qandadiv" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="qandaset" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="reference" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="sect1" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="sect2" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="sect3" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="sect4" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="sect5" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="section" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="set" toc="0" title="1"/>
  </xsl:param>
  

<xsl:template name="t:system-head-content">
  <xsl:param name="node" select="."/>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <!-- system.head.content is like user.head.content, except that
       it is called before head.content. This is important because it
       means, for example, that <style> elements output by system-head-content
       have a lower CSS precedence than the users stylesheet. -->

  <!-- See http://remysharp.com/2009/01/07/html5-enabling-script/ -->
  <!--
  <xsl:comment>[if lt IE 9]>
&lt;script src="http://html5shim.googlecode.com/svn/trunk/html5.js">&lt;/script>
&lt;![endif]</xsl:comment>
  -->
</xsl:template>

<xsl:template name="t:javascript">
  <xsl:param name="node" select="."/>

  <xsl:if test="//db:annotation">
    <script type="text/javascript" src="{concat($resource.root, 'js/AnchorPosition.js')}">&#160;</script>
    <script type="text/javascript" src="{concat($resource.root, 'js/PopupWindow.js')}">&#160;</script>
    <script type="text/javascript" src="{concat($resource.root, 'js/annotation.js')}">&#160;</script>
  </xsl:if>

  <script type="text/javascript" src="{concat($resource.root, 'js/dbmodnizr.js')}">&#160;</script>
  
   <!-- Rackspace stuff -->
  <script type="text/javascript" src="http://rackspace.com/min/?g=js-header&amp;1332945039"><xsl:comment/></script>
  <link rel="stylesheet" type="text/css" href="http://rackspace.com/min/?g=css&amp;1333990221" />
  <link rel="stylesheet" type="text/css" href="http://rackspace.com/min/?f=css/managed.rackspace.css" />
  <link rel="stylesheet" type="text/css" href="http://docs.rackspace.com/common/css/newformat.css"/>
  <script type="text/javascript" src="http://docs.rackspace.com/common/newformat.js"><xsl:comment/></script>
  <!-- Rackspace stuff -->
  
</xsl:template>

  <xsl:param name="docbook.css" select="''"/>

<xsl:param name="autolabel.elements">
  <db:refsection/>
</xsl:param>

  <xsl:template match="/" priority="10">
    <xsl:choose>
      <xsl:when test="$rootid = ''">
        <xsl:apply-templates select="$chunks" mode="m:chunk"/>
      </xsl:when>
      <xsl:when test="$chunks[@xml:id = $rootid]">
        <xsl:apply-templates select="$chunks[@xml:id = $rootid]" mode="m:chunk"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>There is no chunk with the ID: </xsl:text>
          <xsl:value-of select="$rootid"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <db:book/>
    
    <xsl:result-document 
        href="{$base.dir}/bookinfo.xml" 
        method="xml" indent="yes" encoding="UTF-8">
<!--      <products xmlns="">
        <product>
          <id>1</id>
          <types>
            <type>
              <id>1</id>
              <displayname>Legal notice</displayname>
              <url>/example/example-foo.html</url>
              <sequence>2</sequence> 
            </type>
            <type>
              <id>2</id>
              <displayname>Overview</displayname>
              <url>/example/Overview.html</url>
              <sequence>2</sequence>
            </type>
            <type>
              <id>2</id>
              <displayname>Intended Audience</displayname>
              <url>/example/section_eow_tmw_ad.html</url>
              <sequence>2</sequence>
            </type>
          </types>     
        </product>
      </products>  -->    
      
      <xsl:variable name="productid">
      	<xsl:choose>
      		<xsl:when test="//db:productname"><xsl:apply-templates select="//db:productname" mode="bookinfo"/></xsl:when>
      		<xsl:otherwise>1</xsl:otherwise>
      	</xsl:choose>
      </xsl:variable>
      
      <products xmlns="">
        <product>
          <!-- HACK...FIXME -->
          <id><xsl:value-of select="$productid"/></id>
           <types>
      <xsl:choose>
        <xsl:when test="$rootid = ''">
          <xsl:apply-templates select="$chunks" mode="bookinfo"/>
        </xsl:when>
        <xsl:when test="$chunks[@xml:id = $rootid]">
          <xsl:apply-templates select="$chunks[@xml:id = $rootid]" mode="bookinfo"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">
            <xsl:text>There is no chunk with the ID: </xsl:text>
            <xsl:value-of select="$rootid"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
           </types>
        </product>
      </products>
    </xsl:result-document>
    
    <xsl:result-document 
      href="{$base.dir}/WEB-INF/web.xml" 
      method="xml" indent="yes" encoding="UTF-8">
      <web-app version="2.4" xmlns="http://java.sun.com/xml/ns/j2ee"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="
        http://java.sun.com/xml/ns/j2ee  http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd">
       <xsl:comment>Noop</xsl:comment>
      </web-app>
    </xsl:result-document>
    
  </xsl:template>
  
  <xsl:template match="db:book|db:chapter|db:preface|db:section|db:appendix|db:glossary|db:part|db:index" mode="bookinfo">
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="processing-instruction('rax')">
          <xsl:value-of select="f:pi(processing-instruction('rax'),'type')"/>
        </xsl:when>
        <xsl:when test="ancestor::*[processing-instruction('rax')]">
          <xsl:value-of select="f:pi(ancestor::*[processing-instruction('rax')]/processing-instruction('rax')[1],'type')"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="idNumber">
      <xsl:choose>
        <xsl:when test="$type = 'concepts'">1</xsl:when>
        <xsl:when test="$type = 'apiref'">2</xsl:when>
        <xsl:when test="$type = 'advanced'">3</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="priority"><xsl:value-of select="f:pi(processing-instruction('rax'),'priority')"/></xsl:variable>
    
    <xsl:variable name="priorityCalculated">
      <xsl:choose>
        <xsl:when test="normalize-space($priority) != ''">
          <xsl:value-of select="normalize-space($priority)"/>
        </xsl:when>
        <xsl:otherwise>100000</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <type xmlns="">
      <id><xsl:value-of select="$idNumber"/></id>
      <displayname><xsl:value-of select="db:title|db:info/db:title"/></displayname>
      <url>/example/<xsl:value-of select="f:chunk-filename(.)"/></url>
      <sequence><xsl:value-of select="$priorityCalculated"/></sequence> 
    </type>
    <xsl:apply-templates select="db:book|db:chapter|db:preface|db:section|db:appendix|db:glossary|db:part|db:index" mode="bookinfo"/>
  </xsl:template>

  <xsl:template match="db:productname" mode="bookinfo">
    <xsl:choose>
      <xsl:when test="preceding::db:productname"/>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Servers')">1</xsl:when>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Databases')">2</xsl:when>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Monitoring')">3</xsl:when>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Block Storage')">4</xsl:when>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Files')">5</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>  
  </xsl:template>
  
  <xsl:template match="text()" mode="bookinfo"/>

  <xsl:template match="*" mode="m:chunk" priority="10">
    <xsl:variable name="chunkfn" select="f:chunk-filename(.)"/>
    
    <xsl:variable name="pinav"
      select="(f:pi(./processing-instruction('dbhtml'), 'navigation'),'true')[1]"/>
    
    <xsl:variable name="chunk" select="key('id', generate-id(.), $chunk-tree)"/>
    <xsl:variable name="nchunk" select="($chunk/following::h:chunk|$chunk/descendant::h:chunk)[1]"/>
    <xsl:variable name="pchunk" select="($chunk/preceding::h:chunk|$chunk/parent::h:chunk)[last()]"/>
    <xsl:variable name="uchunk" select="$chunk/ancestor::h:chunk[1]"/>
    
    <!--
    <xsl:message>Creating chunk: <xsl:value-of select="concat($base.dir,$chunkfn)"/></xsl:message>
    -->
    
    <xsl:result-document href="{$base.dir}{$chunkfn}" method="xhtml" indent="no">
      <html>
        <xsl:call-template name="t:head">
          <xsl:with-param name="node" select="."/>
        </xsl:call-template>
        <body  class="hybrid-home">


	  <!-- START HEADER -->
		<div id="page-darken-wrap">&#160;</div>
		<div id="page-wrap">
			<div id="ceiling-wrap">
				<div class="container_12" id="pocket-container">
					<div id="pocket-wrap">
						<div id="pocket-livechat" class="pocketitem">
							<div class="icon">&#160;</div>
							<div class="content" onclick="track_chat_button('Home: Header: Live Chat');launchChatWindow('39941')">
								<span class="pocketitem-gray">Live Chat</span>
							</div>
						</div>
						<div id="pocket-salesnumber" class="pocketitem">
							<div class="icon">&#160;</div>
							<div class="content">
								<span class="pocketitem-gray">Sales:</span> 1-800-961-2888
							</div>
						</div>
						<div id="pocket-supportnumber" class="pocketitem">
							<a href="/support/"></a>
							<div class="icon">&#160;</div>
							<div class="content">
								<a href="/support/"><span class="pocketitem-gray">Support:</span></a> 1-800-961-4454
							</div>
						</div>
						<div class="clear">&#160;</div>
					</div>
					<div id="navigation-wrap">
						<div id="logo-wrap" onclick="getURL('/')">&#160;</div>
						<div id="menu-wrap">
							<div class='menuoption' id='menuoption-hostingsolutions'>
								<a href="/hosting_solutions/" class="menuoption menuoption-off">Getting Started</a>
								<div class='menu' id='menu-hostingsolutions'>
									<div class='container_12'>
										<div class='navigation_1'>
											<div class='menu-title'>
												Hosting Solutions
											</div><br />
											<br />
										</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-link'>
													<a href="/hosting_solutions/">Solutions</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/hosting_solutions/websites/">Corporate Websites</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/hosting_solutions/customapps/">Custom Applications</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/hosting_solutions/ecommerce/">E-commerce Websites</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/hosting_solutions/richmedia/">Rich Media Websites</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/hosting_solutions/saas/">SaaS Applications</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/hosting_solutions/testdev/">Test &amp; Development Environments</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/enterprise_hosting/">Enterprise Business Solutions</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/enterprise_hosting/advisory_services/">Advisory Services</a>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='grid_divider_vertical'>&#160;</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-link'>
													<a href="/hosting_solutions/">Technologies</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/">Cloud Hosting</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/cloud/cloud_hosting_products/servers/">Cloud Servers™</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/cloud/managed_cloud/">Cloud Servers™ - Managed</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/cloud/cloud_hosting_products/sites/">Cloud Sites™</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/cloud/cloud_hosting_products/loadbalancers/">Cloud Load Balancers</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/cloud/cloud_hosting_products/files/">Cloud Files™</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/cloud/cloud_hosting_products/monitoring/">Cloud Monitoring</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/cloud/cloud_hosting_products/dns/">Cloud DNS</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/cloud/private_edition/">Cloud Private Edition</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/">Managed Hosting</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/managed_hosting/configurations/">Managed Server Configurations</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/managed_hosting/private_cloud/">Private Clouds</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/managed_hosting/managed_colocation/">Managed Colocation Servers</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/managed_hosting/services/proservices/criticalsites/">Rackspace Critical Sites</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/hosting_solutions/hybrid_hosting/">Hybrid Hosting</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/hosting_solutions/hybrid_hosting/rackconnect/">RackConnect™</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps">Email &amp; Apps</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/apps/email_hosting/rackspace_email/">Rackspace Email</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/apps/email_hosting/exchange_hosting/">Microsoft Exchange</a>
													<div class='clear'>&#160;</div>
												</li>
												<li style="list-style: none">/
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/apps/file_sharing/">File Sharing</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/apps/backup_and_collaboration/">Backup &amp; Collaboration</a>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='grid_divider_vertical'>&#160;</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-link'>
													<a href="/cloud/private_edition/">Cloud Builders</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/private_edition/">Cloud Private Edition</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/private_edition/openstack/">About OpenStack™</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/private_edition/training/">Rackspace Training</a>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='clear'>&#160;</div>
									</div>
								</div>
							</div>
							<div class='menuoption' id='menuoption-cloud'>
								<a href="/cloud/" class="menuoption menuoption-off">API Documentation</a>
								<div class='menu' id='menu-cloud'>
									<div class='container_12'>
										<div class='navigation_1'>
											<div class='menu-title'>
												Cloud Hosting
											</div><br />
											<br />
											<div class='rsOrderButton horizontal' url='https://cart.rackspace.com/cloud/'>
												Order Now
											</div>
											<div class='rsSupport' onclick='getURL("/support/")'>
												Help &amp; Support
											</div>
										</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-link'>
													<a href="/cloud/cloud_hosting_products/">Cloud Products</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/cloud_hosting_products/">Overview</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/cloud_hosting_products/servers/">Cloud Servers™</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/managed_cloud/">Cloud Servers™ - Managed</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/cloud_hosting_products/sites/">Cloud Sites™</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/cloud_hosting_products/loadbalancers/">Cloud Load Balancers</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/cloud_hosting_products/files/">Cloud Files™</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/cloud_hosting_products/monitoring/">Cloud Monitoring</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/cloud_hosting_products/dns/">Cloud DNS</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/private_edition/">Cloud Private Edition</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-link'>
													<a href="/cloudreseller/">Partner Program</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloudreseller/">Program Overview</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="https://affiliates.rackspacecloud.com/">Cloud Affiliates</a>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='grid_divider_vertical'>&#160;</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-link'>
													<a href="/cloud/cloud_hosting_faq/">Learn More</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/cloud_hosting_faq/">Cloud FAQ</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/who_uses_cloud_computing/">Cloud Customers</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/what_is_cloud_computing/">Cloud Computing?</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/knowledge_center/cloudu/">Cloud University</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/cloud_hosting_demos/">Cloud Demos</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/knowledge_center/">Knowledge Center</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-link'>
													<a href="/cloud/tools/">Cloud Tools</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='grid_divider_vertical'>&#160;</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-link'>
													<a href="/cloud/aboutus/story/">About</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/aboutus/story/">Our Story</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/aboutus/contact/">Contact Us</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/information/newsroom/">Media</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/aboutus/events/">Events</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="http://www.rackertalent.com/">Jobs</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/information/links/">Link to Us</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/cloud/legal/">Legal</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-link'>
													<a href="/blog/channels/cloud-industry-insights/">Blog</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='clear'>&#160;</div>
									</div>
								</div>
							</div>
							<div class='menuoption' id='menuoption-managed'>
								<a href="/managed_hosting/" class="menuoption menuoption-off">Core Concepts</a>
								<div class='menu' id='menu-managed'>
									<div class='container_12'>
										<div class='navigation_1'>
											<div class='menu-title'>
												Managed Hosting
											</div><br />
											<br />
											<div class='rsOrderButton horizontal' url='/managed_hosting/configurations/'>
												Order Now
											</div>
											<div class='rsSupport' onclick='getURL("/support/")'>
												Help &amp; Support
											</div>
										</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-link'>
													<a href="/managed_hosting/">Managed Solutions</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/private_cloud/">Managed Private Clouds</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/managed_colocation/">Managed Colocation</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/configurations/">Managed Server Configurations</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-link'>
													<a href="/partners/">Partner Program</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='grid_divider_vertical'>&#160;</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-link'>
													<a href="/managed_hosting/dedicated_servers/">Compare Managed</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-link'>
													<a href="/managed_hosting/support/">Support Experience</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/support/dedicatedteam/">Dedicated Support Teams</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/support/promise/">The Fanatical Support Promise<sup>®</sup></a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/support/customers/">Our Customers</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/support/servicelevels/">Managed Service Levels</a>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='grid_divider_vertical'>&#160;</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-link'>
													<a href="/managed_hosting/services/">Managed Services</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/services/security/">Managed Security</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/services/storage/">Managed Storage</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/services/database/">Managed Databases</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/services/proservices/sharepoint/">Dedicated Microsoft<sup>®</sup> SharePoint</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/services/proservices/criticalsites/">Rackspace Critical Sites</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/managed_hosting/services/proservices/disasterrecovery/">Disaster Recovery Services</a>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='clear'>&#160;</div>
									</div>
								</div>
							</div>
							<div class='menuoption' id='menuoption-email'>
								<a href="/apps" class="menuoption menuoption-off">Advanced Topics</a>
								<div class='menu' id='menu-email'>
									<div class='container_12'>
										<div class='navigation_1'>
											<div class='menu-title'>
												Email &amp; Apps
											</div><br />
											<br />
											<div class='rsOrderButton horizontal' url='https://cart.rackspace.com/apps/'>
												Free Trial
											</div>
											<div class='rsSupport' onclick='getURL("/apps/support/")'>
												Email Help &amp; Support
											</div>
										</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-link'>
													<a href="/apps">Our Apps</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/email_hosting/">Email Hosting</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/apps/email_hosting/rackspace_email/">Rackspace Email</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/apps/email_hosting/exchange_hosting/">Microsoft Exchange</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/apps/email_hosting/exchange_hybrid/">Exchange Hybrid</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/file_sharing/">File Sharing</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/apps/file_sharing/hosted_sharepoint/">Microsoft SharePoint</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/backup_and_collaboration/">Backup &amp; Collaboration</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/apps/backup_and_collaboration/online_file_storage/">Rackspace Cloud Drive</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/apps/backup_and_collaboration/data_backup_software/">Rackspace Server Backup</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/apps/email_hosting/email_archiving/">Email Archiving</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-label'>Admin Tools
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/control_panel/">Control Panel</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/email_hosting/migrations/">Migrations App</a>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='grid_divider_vertical'>&#160;</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-label'>Mobile Options
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/email_hosting/rackspace_email/on_your_mobile/">For Rackspace Email</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/email_hosting/exchange_hosting/on_your_mobile/">For Microsoft Exchange</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-label'>Email Extras
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/email_hosting/compare/">Compare Products</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/email_marketing_solutions/">Email Marketing</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-link'>
													<a href="/apps/why_hosted_apps/">Why Rack Apps</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/why_hosted_apps/">Top 10 Reasons</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/whyrackspace/support/">Fanatical Support</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/email_industry_leadership/">History &amp; Expertise</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/customers/">Customer Case Studies</a>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='grid_divider_vertical'>&#160;</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-label'>Considering a Switch?
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/email_hosting_service_planning_guide/">Get Your Business Ready</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/email_provider/">Select Your Provider</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/email_hosting/migrations/">Migrate Your Data</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-link'>
													<a href="/information/contactus/" rel="nofollow">Connect With Us</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/information/contactus/" rel="nofollow">Contact Us</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="http://feedback.rackspacecloud.com">Product Feedback</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/apps/careers/">Careers</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-link'>
													<a href="/partners/">Partner Program</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-link'>
													<a href="/apps/support/">Help &amp; Support</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='clear'>&#160;</div>
									</div>
								</div>
							</div>
							<div class='menuoption' id='menuoption-rackspace'>
								<a href="/" class="menuoption menuoption-off">Tools</a>
								<div class='menu' id='menu-rackspace'>
									<div class='container_12'>
										<div class='navigation_1'>
											<div class='menu-title'>
												About the Company
											</div><br />
											<br />
										</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-link'>
													<a href="/whyrackspace/">Why Rackspace</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/whyrackspace/support/">Fanatical Support®</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/whyrackspace/network/">Our Network</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/whyrackspace/network/datacenters/">Our Data Centers</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/whyrackspace/network/ipv6/">IPv6 Deployment &amp; Readiness</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/whyrackspace/expertise/">Awards &amp; Expertise</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-link'>
													<a href="/partners/">Partner Program</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/partners/">Program Overview</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/forms/partnerapplication/">Partner Application</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="http://rackspacepartner.force.com/us">Partner Portal Login</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/partners/partnersearch/">Partner Locator</a>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='grid_divider_vertical'>&#160;</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-link'>
													<a href="/information/">Information Center</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/information/aboutus/">About Rackspace</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/information/newsroom/">Rackspace Newsroom</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/information/contactus/" rel="nofollow">Contact Information</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/information/aboutus/">Leadership</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/information/hosting101/">Hosting 101</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/information/events/" rel="nofollow">Programs &amp; Events</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/startup/">Rackspace Startup Program</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/information/events/rackgivesback/" rel="nofollow">Rack Gives Back</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='sub'>
													<div class='arrow'>&#160;</div><a href="/information/events/briefingprogram/">Briefing Program</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="http://www.rackertalent.com">Careers</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="http://ir.rackspace.com/phoenix.zhtml?c=221673&amp;p=irol-irhome">Investors</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/information/legal/">Legal</a>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='grid_divider_vertical'>&#160;</div>
										<div class='navigation_2'>
											<ul class='navigation'>
												<li class='heading-label'>Blog Community
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="/blog/">The Official Rackspace Blog</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="http://www.rackertalent.com">Racker Talent</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class=''>
													<a href="http://www.building43.com">Building 43</a>
													<div class='clear'>&#160;</div>
												</li>
												<li class='heading-link'>
													<a href="/knowledge_center/">Knowledge Center</a>
													<div class='arrow'>&#160;</div>
													<div class='clear'>&#160;</div>
												</li>
											</ul>
										</div>
										<div class='clear'>&#160;</div>
									</div>
								</div>
							</div>
						</div>
						<div id="search-wrap">
							<form id="sitesearch" name="sitesearch" action="/searchresults/" onsubmit="return submitSiteSearch()">
								<input type="text" name="q" id="search" value="Search" onclick="cleanSlate('search')" autocomplete="off" style="color:#CCCCCC" />
								<div id="search-button" class="inactive" onclick="submitForm('sitesearch')">&#160;</div>
							</form>
						</div>
					</div>
				</div>
			</div>

			<!-- END HEADER -->

			<div id="content-home-wrap">
				<div class="container_12">
					<div id="sidebar">
						<div id="treeDiv">
							<div id="ulTreeDiv">
								<ul id="tree" class="filetree">
									<li tabindex="2">
										<span ><a href="Introduction.html">Introduction</a></span>
										<ul style="display:none">
											<li tabindex="2">
												<span ><a href="how-it-works.html">How Rackspace Cloud Monitoring Works</a></span>
											</li>
											<li tabindex="2">
												<span ><a href="pre-reqs.html">Prerequisites</a></span>
											</li>
											<li tabindex="2">
												<span ><a href="endpoint-access.html">Accessing the API</a></span>
											</li>
											<li tabindex="2">
												<span ><a href="Authentication.html">Authentication</a></span>
												<ul>
													<li tabindex="2">
														<span ><a href="Authentication.html#auth-endpoint">The Authentication Endpoint</a></span>
													</li>
													<li tabindex="2">
														<span ><a href="Authentication.html#finding-key">The Authentication Process</a></span>
													</li>
													<li tabindex="2">
														<span ><a href="Authentication.html#example-auth">Example Authentication</a></span>
													</li>
													<li tabindex="2">
														<span ><a href="Authentication.html#auth-response-description">Authentication Response Description</a></span>
													</li>
												</ul>
											</li>
											<li tabindex="2">
												<span ><a href="working-with-tutorial.html">Working with the Exercises in this Guide</a></span>
												<ul>
													<li tabindex="2">
														<span ><a href="curl.html">Using cURL</a></span>
														<ul>
															<li tabindex="2">
																<span ><a href="curl-copying-examples.html">1.Copying Request Examples</a></span>
															</li>
															<li tabindex="2">
																<span ><a href="curl-escaping-returns.html">1.Escaping Carriage Returns</a></span>
															</li>
														</ul>
													</li>
													<li tabindex="2">
														<span ><a href="using-raxmon.html">Using the raxmon Command Line Interface</a></span>
													</li>
												</ul>
											</li>
										</ul>
									</li>
									<li tabindex="2">
										<span ><a href="tutorial.html">Create Your First Monitor</a></span>
										<ul>
											<li tabindex="2" id="currentchapter">
												<span ><a href="#">Create an Entity ipsum lorem foo bar baz</a></span>
											</li>
											<li tabindex="2">
												<span ><a href="concepts-tutorial-monitoring-zones.html">List Monitoring Zones</a></span>
											</li>
											<li tabindex="2">
												<span ><a href="concepts-tutorial-create-checks.html">Create Checks</a></span>
												<ul>
													<li tabindex="2">
														<span ><a href="tutorial-create-ping-check.html">Create a PING Check</a></span>
													</li>
													<li tabindex="2">
														<span ><a href="tutorial-test-check.html">Test the Check</a></span>
													</li>
													<li tabindex="2">
														<span ><a href="tutorial-create-http-check.html">Create HTTP Checks</a></span>
													</li>
												</ul>
											</li>
											<li tabindex="2">
												<span ><a href="tutorial-list-all-checks.html">List All Checks for the Entity</a></span>
											</li>
											<li tabindex="2">
												<span ><a href="concepts-tutorial-setup-notifications.html">Set Up Notifications</a></span>
												<ul>
													<li tabindex="2">
														<span ><a href="create-notification-plan.html">Create a Notification Plan ipsum lorem foo bar baz</a></span>
													</li>
												</ul>
											</li>
											<li tabindex="2" id="webhelp-currentid">
												<span ><a href="concepts-tutorial-create-alarm.html">Create an Alarm</a></span>
											</li>
											<li tabindex="2">
												<span ><a href="concepts-tutorial-modify-entity.html">Modify an Entity</a></span>
											</li>
											<li tabindex="2">
												<span ><a href="concepts-tutorial-delete-entity.html">Delete an Entity</a></span>
											</li>
										</ul>
									</li>
									<li tabindex="2">
										<span ><a href="additional-resources.html">Additional Resources</a></span>
										<ul style="display:none">
											<li tabindex="2">
												<span ><a href="resources-monitoring-docs.html">More on Monitoring</a></span>
											</li>
											<li tabindex="2">
												<span ><a href="resources-talk.html">Talk to Us</a></span>
											</li>
											<li tabindex="2">
												<span ><a href="resouces-talk.html">More From Rackspace</a></span>
											</li>
										</ul>
									</li>
									<li tabindex="2">
										<span ><a href="rs_glossary.html">Glossary</a></span>
									</li>
								</ul>
							</div>
						</div>
					</div>

					<!-- END TOC -->



        	
        
<div id="main-content">
          
          <div class="page">
            <xsl:call-template name="t:body-attributes"/>
            <xsl:if test="@status">
              <xsl:attribute name="class" select="@status"/>
            </xsl:if>
            
            <div class="content">
              <xsl:if test="$pinav = 'true'">
                <xsl:call-template name="t:user-header-content">
                  <xsl:with-param name="node" select="."/>
                  <xsl:with-param name="next" select="key('genid', $nchunk/@xml:id)"/>
                  <xsl:with-param name="prev" select="key('genid', $pchunk/@xml:id)"/>
                  <xsl:with-param name="up" select="key('genid', $uchunk/@xml:id)"/>
                </xsl:call-template>
              </xsl:if>
              
              <div class="body">
                <xsl:apply-templates select=".">
                  <xsl:with-param name="override-chunk" select="true()"/>
                </xsl:apply-templates>
              </div>
            </div>
            
            <xsl:if test="$pinav = 'true'">
              <xsl:call-template name="t:user-footer-content">
                <xsl:with-param name="node" select="."/>
                <xsl:with-param name="next" select="key('genid', $nchunk/@xml:id)"/>
                <xsl:with-param name="prev" select="key('genid', $pchunk/@xml:id)"/>
                <xsl:with-param name="up" select="key('genid', $uchunk/@xml:id)"/>
              </xsl:call-template>
            </xsl:if>
          </div>
  
</div>
          
				</div>
			</div>
		</div>
          <!-- BEGIN FOOTER -->
          <div id="footer-wrap">
            <div id="fatfooter-wrap">
              <div class="container_12">
                <div class='fatfooter_1 push_0'>
                  <div>
                    <a href="/">Rackspace</a>
                  </div>
                  <ul>
                    <li>
                      <a href="/information/aboutus/" class="footer">About Rackspace Hosting</a>
                    </li>
                    <li>
                      <a href="/whyrackspace/support/" class="footer">Fanatical Support®</a>
                    </li>
                    <li>
                      <a href="/hosting_solutions/" class="footer">Hosting Solutions</a>
                    </li>
                    <li>
                      <a href="/information/hosting101/" class="footer">Web Hosting 101</a>
                    </li>
                    <li>
                      <a href="/partners/" class="footer">Hosting Partner Programs</a>
                    </li>
                    <li>
                      <a href="/cloudbuilders/openstack/" class="footer">OpenStack™</a>
                    </li>
                  </ul>
                </div>
                <div class='fatfooter_1 push_1'>
                  <div>
                    <a href="/managed_hosting/">Managed Hosting</a>
                  </div>
                  <ul>
                    <li>
                      <a href="/managed_hosting/configurations/" class="footer">Managed Configurations</a>
                    </li>
                    <li>
                      <a href="/managed_hosting/managed_colocation/" class="footer">Managed Colocation Servers</a>
                    </li>
                    <li>
                      <a href="/managed_hosting/dedicated_servers/" class="footer">Dedicated Servers</a>
                    </li>
                    <li>
                      <a href="/managed_hosting/support/customers/" class="footer">Managed Customers</a>
                    </li>
                    <li>
                      <a href="https://my.rackspace.com" class="footer" rel="nofollow">MyRackspace® Portal</a>
                    </li>
                  </ul>
                </div>
                <div class='fatfooter_1 push_2'>
                  <div>
                    <a href="/cloud/">Cloud Hosting</a>
                  </div>
                  <ul>
                    <li>
                      <a href="/cloud/cloud_hosting_products/servers/" class="footer">Cloud Servers™</a>
                    </li>
                    <li>
                      <a href="/cloud/cloud_hosting_products/sites/" class="footer">Cloud Sites™</a>
                    </li>
                    <li>
                      <a href="/cloud/cloud_hosting_products/loadbalancers/" class="footer">Cloud Load Balancers</a>
                    </li>
                    <li>
                      <a href="/cloud/cloud_hosting_products/files/" class="footer">Cloud Files™</a>
                    </li>
                    <li>
                      <a href="/cloud/cloud_hosting_demos/" class="footer">Cloud Hosting Demos</a>
                    </li>
                    <li>
                      <a href="https://manage.rackspacecloud.com/pages/Login.jsp" class="footer">Cloud Customer Portal</a>
                    </li>
                  </ul>
                </div>
                <div class='fatfooter_1 push_3'>
                  <div>
                    <a href="/apps/">Email &amp; Apps</a>
                  </div>
                  <ul>
                    <li>
                      <a href="/apps/email_hosting/" class="footer">Rackspace Email Hosting</a>
                    </li>
                    <li>
                      <a href="/apps/email_hosting/exchange_hosting/" class="footer">Microsoft Hosted Exchange</a>
                    </li>
                    <li>
                      <a href="/apps/email_hosting/compare/" class="footer">Compare Hosted Products</a>
                    </li>
                    <li>
                      <a href="/apps/email_hosting/email_archiving/" class="footer">Email Archiving</a>
                    </li>
                    <li>
                      <a href="http://apps.rackspace.com/" class="footer">Customer Log-in</a>
                    </li>
                  </ul>
                </div>
                <div class='grid_divider_vertical push_3'>&#160;</div>
                <div class='fatfooter_1 push_4'>
                  <div>
                    <a href="/information/contactus/" rel="nofollow">Contact Us</a>
                  </div>
                  <div>
                    <a href=""></a>
                  </div>
                  <div class='column_1'>
                    <div class="footerIcon salesIcon">&#160;</div><span style="color:#4F81A6;">Sales</span>
                  </div>
                  <div class='column_2'>
                    1-800-961-2888
                  </div>
                  <div class='clear'>&#160;</div>
                  <div class='column_1'>
                    <a href="/support/"></a>
                    <div class="footerIcon supportIcon">&#160;</div><span style="position:relative; color:#4F81A6;">Support</span>
                  </div>
                  <div class='column_2'>
                    1-800-961-4454
                  </div>
                  <div class='clear'>&#160;</div><br />
                  <div>
                    <a href="/information/contactus/" rel="nofollow">Connect With Us</a>
                  </div>
                  <div>
                    <a href=""></a>
                  </div>
                  <div class='social linkedin' onclick='getURLNewWindow("http://www.linkedin.com/company/rackspace-hosting/")'>&#160;</div>
                  <div class='social facebook' onclick='getURLNewWindow("http://www.facebook.com/rackspacehost")'>&#160;</div>
                  <div class='social twitter' onclick='getURLNewWindow("http://twitter.com/rackspace")'>&#160;</div>
                  <div class='social linktous' onclick='getURLNewWindow("/information/links/")'>&#160;</div>
                  <div class='social email' onclick='getURLNewWindow("/forms/contactsales/")'>&#160;</div>
                  <div class='clear'>&#160;</div>
                </div>
                <div class='clear'>&#160;</div>
              </div>
              <div id="rackerpowered">&#160;</div>
            </div>
          </div>
          <div id="basement-wrap" class="basement-wrap-nosnap">
            ©2012 Rackspace, US Inc. <span class='footerlink'><a href="/information/aboutus/" class="basement">About Rackspace</a></span> | <span class='footerlink'><a href="/whyrackspace/support/" class="basement">Fanatical Support®</a></span> | <span class='footerlink'><a href="/hosting_solutions/" class="basement">Hosting Solutions</a></span> | <span class='footerlink'><a href="http://ir.rackspace.com" class="basement">Investors</a></span> | <span class='footerlink'><a href="http://www.rackertalent.com" class="basement">Careers</a></span> | <span class='footerlink'><a href="/information/legal/privacystatement/" class="basement">Privacy Statement</a></span> | <span class='footerlink'><a href="/information/legal/websiteterms/" class="basement">Website Terms</a></span> | <span class='footerlink'><a href="/sitemap/" class="basement" rel="nofollow">Sitemap</a></span>
          </div>
          <script type="text/javascript" src="http://docs.rackspace.com/common/jquery/qtip/jquery.qtip.js"><!--jQuery plugin for  popups. -->
                   $('a[title]').qtip({ style: { background:green, name: 'cream', tip: true } })
                </script>
               
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>
  
  
  <xsl:template name="anchor">
    <xsl:param name="node" select="."/>
    <xsl:param name="force" select="0"/>
    
    <xsl:if test="$force != 0 or ($node/@id or $node/@xml:id)">
      <a name="{f:node-id($node)}" id="{f:node-id($node)}">&#160;</a>
    </xsl:if>
  </xsl:template>
  

</xsl:stylesheet>