<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="d"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
		xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

  <!-- <xsl:import href="urn:docbkx:stylesheet-orig/xsl/webhelp.xsl" /> -->
  <xsl:import href="webhelp.xsl" />

  <xsl:param name="section.autolabel" select="1"/>
  <xsl:param name="chapter.autolabel" select="1"/>
  <xsl:param name="appendix.autolabel" select="1"/>
  <xsl:param name="part.autolabel" select="1"/>
  <xsl:param name="reference.autolabel" select="1"/>
  <xsl:param name="qandadiv.autolabel" select="1"/>
  <xsl:param name="webhelp.autolabel" select="1"/>
  <xsl:param name="section.autolabel.max.depth" select="3"/>
  <xsl:param name="section.label.includes.component.label" select="1"/>
  <xsl:param name="component.label.includes.part.label" select="1"/>
  <xsl:param name="ignore.image.scaling" select="1"/>
  <xsl:param name="suppress.footer.navigation">1</xsl:param>

  <xsl:param name="branding">not set</xsl:param>
  <xsl:param name="enable.disqus">0</xsl:param>
  <xsl:param name="disqus.shortname">rackspacedocs</xsl:param>
  <xsl:param name="brandname">
    <xsl:choose>
      <xsl:when test="$branding = 'openstack'">OpenStack</xsl:when>
      <xsl:otherwise>Rackspace</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="main.docs.url">
    <xsl:choose>
      <xsl:when test="$branding = 'openstack'">http://docs.openstack.org/</xsl:when>
      <xsl:otherwise>http://docs.rackspacecloud.com/api/</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

    <xsl:template name="user.footer.content">

        <script type="text/javascript" src="../common/main.js">
            <xsl:comment></xsl:comment>
        </script>
        
	<xsl:if test="$enable.disqus != '0'">
	  <hr />
	  
	  <h2 class="userNotes">User Notes On This Page</h2>
	  <div id="disqus_thread">
	    <script type="text/javascript">
	      /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
	      var disqus_shortname = '<xsl:value-of select="$disqus.shortname"/>'; 
	      
	      <!-- // The following are highly recommended additional parameters. Remove the slashes in front to use. -->
	      <!-- // var disqus_identifier = 'unique_dynamic_id_1234'; -->
	      <!-- // var disqus_url = 'http://example.com/permalink-to-page.html'; -->
	      
	      <!-- /* * * DON'T EDIT BELOW THIS LINE * * */ -->
	      (function() {
	      var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
	      dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
	      (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
	      })();
	    </script>
	    <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
	    <a href="http://disqus.com" class="dsq-brlink">User notes powered by <span class="logo-disqus">Disqus</span></a>
	  </div>
	</xsl:if>    

    </xsl:template>

      <xsl:template name="webhelpheader">
        <xsl:param name="prev"/>
        <xsl:param name="next"/>
        <xsl:param name="nav.context"/>
        
        <xsl:variable name="home" select="/*[1]"/>
        <xsl:variable name="up" select="parent::*"/>
        
        <div id="header">
            <img src='../common/images/{$branding}-logo.png' alt="{$brandname} Documentation" width="157" height="47" />
	    <p class="breadcrumbs"><a href="{$main.docs.url}"><xsl:value-of select="$brandname"/> Manuals</a>  <a href="{$default.topic}"><xsl:value-of select="normalize-space(//d:title[1])"/><xsl:apply-templates select="//d:releaseinfo[1]" mode="rackspace-title"/></a></p>
            
            <!-- Display the page title and the main heading(parent) of it-->
            <h1>
                <xsl:apply-templates select="." mode="object.title.markup"/>
             </h1>
            
            <!-- Prev and Next links generation-->
            <div id="navheader" align="right">
                <xsl:comment>
                    <!-- KEEP this code. In case of neither prev nor next links are available, this will help to
                        keep the integrity of the DOM tree-->
                </xsl:comment>
                <!--xsl:with-param name="prev" select="$prev"/>
                    <xsl:with-param name="next" select="$next"/>
                    <xsl:with-param name="nav.context" select="$nav.context"/-->
                <table class="navLinks">
                    <tr>
                        <td>
                            <a id="showHideButton" onclick="showHideToc();"
                                class="pointLeft" title="Hide TOC tree">Sidebar
                            </a>
                        </td>
                        <xsl:if test="count($prev) &gt; 0
                            or (count($up) &gt; 0
                            and generate-id($up) != generate-id($home)
                            and $navig.showtitles != 0)
                            or count($next) &gt; 0">
                            <td>
                                <xsl:if test="count($prev)>0">
                                    <a accesskey="p" class="navLinkPrevious">
                                        <xsl:attribute name="href">
                                            <xsl:call-template name="href.target">
                                                <xsl:with-param name="object" select="$prev"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                        <xsl:call-template name="navig.content">
                                            <xsl:with-param name="direction" select="'prev'"/>
                                        </xsl:call-template>
                                    </a>
                                </xsl:if>
                                
                                <!-- "Up" link-->
                                <xsl:choose>
                                    <xsl:when test="count($up)&gt;0
                                        and generate-id($up) != generate-id($home)">
                                        |
                                        <a accesskey="u" class="navLinkUp">
                                            <xsl:attribute name="href">
                                                <xsl:call-template name="href.target">
                                                    <xsl:with-param name="object" select="$up"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:call-template name="navig.content">
                                                <xsl:with-param name="direction" select="'up'"/>
                                            </xsl:call-template>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>&#160;</xsl:otherwise>
                                </xsl:choose>
                                
                                <xsl:if test="count($next)>0">
                                    |
                                    <a accesskey="n" class="navLinkNext">
                                        <xsl:attribute name="href">
                                            <xsl:call-template name="href.target">
                                                <xsl:with-param name="object" select="$next"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                        <xsl:call-template name="navig.content">
                                            <xsl:with-param name="direction" select="'next'"/>
                                        </xsl:call-template>
                                    </a>
                                </xsl:if>
                            </td>
                        </xsl:if>
                        
                    </tr>
                </table>
                
                
                
            </div>
            
        </div>
    </xsl:template>
    
    <xsl:template name="webhelptoc">
        <xsl:param name="currentid"/>
        <xsl:choose>
            <xsl:when test="$rootid != ''">
                <xsl:variable name="title">
                    <xsl:if test="$webhelp.autolabel=1">
                        <xsl:variable name="label.markup">
                            <xsl:apply-templates select="key('id',$rootid)" mode="label.markup"/>
                        </xsl:variable>
                        <xsl:if test="normalize-space($label.markup)">
                            <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:apply-templates select="key('id',$rootid)" mode="title.markup"/>
                </xsl:variable>
                <xsl:variable name="href">
                    <xsl:choose>
                        <xsl:when test="$manifest.in.base.dir != 0">
                            <xsl:call-template name="href.target">
                                <xsl:with-param name="object" select="key('id',$rootid)"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="href.target.with.base.dir">
                                <xsl:with-param name="object" select="key('id',$rootid)"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:variable name="title">
                    <xsl:if test="$webhelp.autolabel=1">
                        <xsl:variable name="label.markup">
                            <xsl:apply-templates select="/*" mode="label.markup"/>
                        </xsl:variable>
                        <xsl:if test="normalize-space($label.markup)">
                            <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:apply-templates select="/*" mode="title.markup"/>
                </xsl:variable>
                <xsl:variable name="href">
                    <xsl:choose>
                        <xsl:when test="$manifest.in.base.dir != 0">
                            <xsl:call-template name="href.target">
                                <xsl:with-param name="object" select="/"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="href.target.with.base.dir">
                                <xsl:with-param name="object" select="/"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <div>
                    <div id="leftnavigation" style="padding-top:3px; background-color:white;">
                        <div id="tabs">
                            <ul>
                                <li>
                                    <a href="#treeDiv">
                                        <span class="contentsTab">
                                            <xsl:call-template name="gentext">
                                                <xsl:with-param name="key" select="'TableofContents'"/>
                                            </xsl:call-template>
                                        </span>
                                    </a>
                                </li>
                                <xsl:if test="$webhelp.include.search.tab != 'false'">
                                    <li>
                                        <a href="#searchDiv">
                                            <span class="searchTab">
                                                <xsl:call-template name="gentext">
                                                    <xsl:with-param name="key" select="'Search'"/>
                                                </xsl:call-template>
                                            </span>
                                        </a>
                                    </li>
                                </xsl:if>
                            </ul>
                            <div id="treeDiv">
                                <img src="../../../common/images/loading.gif" alt="loading table of contents..."
                                    id="tocLoading" style="display:block;"/>
                                <div id="ulTreeDiv" style="display:none">
                                    <ul id="tree" class="filetree">
                                        <xsl:apply-templates select="/*/*" mode="webhelptoc">
                                            <xsl:with-param name="currentid" select="$currentid"/>
                                        </xsl:apply-templates>
                                    </ul>
                                </div>
                                
                            </div>
                            <xsl:if test="$webhelp.include.search.tab != 'false'">
                                <div id="searchDiv">
                                    <div id="search">
                                        <form onsubmit="Verifie(ditaSearch_Form);return false"
                                            name="ditaSearch_Form"
                                            class="searchForm">
                                            <fieldset class="searchFieldSet">
                                                <legend>
                                                    <xsl:call-template name="gentext">
                                                        <xsl:with-param name="key" select="'Search'"/>
                                                    </xsl:call-template>
                                                </legend>
                                                <center>
                                                    <input id="textToSearch" name="textToSearch" type="text"
                                                        class="searchText"/>
                                                    <xsl:text disable-output-escaping="yes"> <![CDATA[&nbsp;]]> </xsl:text>
                                                    <input onclick="Verifie(ditaSearch_Form)" type="button"
                                                        class="searchButton"
                                                        value="Go" id="doSearch"/>
                                                </center>
                                            </fieldset>
                                        </form>
                                    </div>
                                    <div id="searchResults">
                                        <center> </center>
                                    </div>
                                    <p class="searchHighlight"><a href="#" onclick="toggleHighlight()">Search Highlighter (On/Off)</a></p>
                                </div>
                            </xsl:if>
                            
                        </div>
                    </div>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
