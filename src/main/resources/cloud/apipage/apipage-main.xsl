<?xml version="1.0" encoding="utf-8"?>
        <xsl:stylesheet
          xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
          xmlns:xlink="http://www.w3.org/1999/xlink"
          xmlns:xhtml="http://www.w3.org/1999/xhtml"
          xmlns:wadl="http://wadl.dev.java.net/2009/02"
          xmlns:rax="http://docs.rackspace.com/api"
          xmlns:d="http://docbook.org/ns/docbook"
          xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0"
          xmlns="http://www.w3.org/1999/xhtml"
          exclude-result-prefixes="xhtml xsdxt rax d" version="2.0">

          <xsl:character-map name="comment">
            <xsl:output-character character="«" string="&lt;"/>
            <xsl:output-character character="»" string="&gt;"/>
            <xsl:output-character character="§" string='"'/>
          </xsl:character-map>

          <xsl:output
            method="xhtml"
             doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
             doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
             use-character-maps="comment"
          indent="no"/>

          <xsl:param name="wadl.norequest.msg"><p class="nobody">This operation does not require a request body.</p></xsl:param>
          <xsl:param name="wadl.noresponse.msg"><p class="nobody">This operation does not return a response body.</p></xsl:param>
          <xsl:param name="wadl.noreqresp.msg"><p class="nobody">This operation does not require a request body and does not return a response body.</p></xsl:param>
	  <xsl:param name="googleAnalyticsId"/>
	  <xsl:param name="googleAnalyticsDomain"/>
	  <xsl:param name="enableGoogleAnalytics">0</xsl:param>

          <xsl:template match="node() | @*">
            <xsl:copy>
              <xsl:apply-templates select="node() | @*"/>
            </xsl:copy>
          </xsl:template>

          <xsl:template match="d:book">
            <html lang="en">
              <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>OpenStack API Documentation</title>
                <link rel="stylesheet" href="apiref/css/bootstrap.min.css"/>
                <!-- OpenStack Specific CSS -->
                <link rel="stylesheet" href="apiref/css/main.css" type="text/css" />
              </head>
              <body>
                <div class="navbar navbar-default" role="navigation">
                  <!-- Brand and toggle get grouped for better mobile display -->
                  <div class="container">
                    <div class="navbar-header">
                      <button type="button" class="navbar-toggle" data-toggle="collapse"
                              data-target="#bs-example-navbar-collapse-1">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                      </button>
                      <a class="navbar-brand" href="/">Open Stack</a>
                    </div>

                    <!-- Collect the nav links, forms, and other content for toggling -->
                    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                      <ul class="nav navbar-nav">
                        <li><a href="http://www.openstack.org" title="Go to the Home page">Home</a></li>
                        <li><a href="http://www.openstack.org/projects" title="Go to the OpenStack Projects page">Projects</a></li>
                        <li><a href="http://www.openstack.org/user-stories" title="Go to the OpenStack user stories page">User Stories</a></li>
                        <li><a href="http://www.openstack.org/community" title="Go to the Community page">Community</a></li>
                        <li><a href="http://www.openstack.org/blog" title="Go to the OpenStack Blog">Blog</a></li>
                        <li><a href="http://wiki.openstack.org/" title="Go to the OpenStack Wiki">Wiki</a></li>
                        <li class="active"><a href="http://docs.openstack.org/" title="Go to OpenStack Documentation">Documentation</a></li>
                      </ul>
                    </div>
                  </div>
                  <!-- /.navbar-collapse -->
                </div>
                <div class="container">
                  <div class="row">
                    <div class="col-md-3">
                      <div class="api-sidebar" data-spy="affix" data-offset-top="80" data-offset-bottom="0">
                        <ul class="nav api-sidenav">
                          <xsl:apply-templates select="d:chapter" mode="toc"/>
                          <li>
                            <xsl:apply-templates
                              select="//d:preface//d:title"
                              mode="menu-toc"/>
                            <ul class="nav active">
                              <xsl:apply-templates
                                select="//d:preface//d:itemizedlist[@xml:id='service-list']/d:listitem/d:para/d:link"
                                mode="menu-toc"/>
                            </ul>
                          </li>
                        </ul>
                        <div class="row">
                          <div class="col-md-7">
                            <label class="sr-only" for="search-box">Search on this page</label>
                            <input type="text" class="form-control" id="search-box" placeholder="Search this page"></input>
                          </div>
                          <div class="col-md-5">
                            <button id="search-btn" class="btn btn-default">Search</button>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col-md-9 api-documentation">
                      <xsl:apply-templates/>
                    </div>
                  </div>
                  <div class="row">
                    <div class="col-md-3"></div>
                    <div class="col-md-9" id="footer">
                      <p>The OpenStack project is provided under the Apache 2.0 license.</p>
                    </div>
                  </div>
                </div>
                <script type="text/javascript" src="apiref/js/jquery-1.10.2.min.js"></script>
                <script type="text/javascript" src="apiref/js/bootstrap.min.js"></script>
                <script type="text/javascript" src="apiref/js/api-site.js"></script>
		<xsl:if test="$enableGoogleAnalytics != '0'">
                <script type="text/javascript">
                  var _gaq = _gaq || [];
                  _gaq.push(['_setAccount', '<xsl:value-of select="$googleAnalyticsId"/>']);
		  _gaq.push(['_setDomainName', '<xsl:value-of select="$googleAnalyticsDomain"/>']);
                  _gaq.push(['_trackPageview']);
                  (function () {
                    var ga = document.createElement('script');
                    ga.type = 'text/javascript';
                    ga.async = true;
                    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                    var s = document.getElementsByTagName('script')[0];
                    s.parentNode.insertBefore(ga, s);\
                  })();
                </script>
		</xsl:if>
              </body>
            </html>
          </xsl:template>

          <xsl:template match="d:preface|d:chapter">
            <div id="{@xml:id}">
              <div class="subhead">
                <h2><xsl:value-of select="d:title"/>
                  <a class="headerlink" title="Permalink to this headline" href="#{@xml:id}">
                    <span class="glyphicon glyphicon-link"></span>
                  </a>
                </h2>
              </div>
              <xsl:apply-templates select="node()[not(self::d:title)]"/>
            </div>
          </xsl:template>

          <xsl:template match="d:section" mode="toc">
            <li><a href="#{@xml:id}"><xsl:value-of select="d:title"/></a></li>
          </xsl:template>

          <xsl:template match="//d:preface//d:title" mode="menu-toc">
            <li>
              <a href="api-ref.html"><xsl:value-of select="."/></a>
            </li>
          </xsl:template>

          <xsl:template match="d:link" mode="menu-toc">
            <li>
              <a href="{@xlink:href}">
                <xsl:value-of select="."/>
              </a>
            </li>
          </xsl:template>
          <!-- Do nothing when you see this list - just used to seed the menu -->
          <xsl:template match="d:itemizedlist[@xml:id='service-list']"/>
          <xsl:template match="d:section">
            <div id="{@xml:id}">
              <div class="subhead">
                <h3><xsl:value-of select="d:title"/>
                  <a class="headerlink" title="Permalink to this headline" href="#{@xml:id}">
                    <span class="glyphicon glyphicon-link"></span>
                  </a>
                </h3>
              </div>
              <xsl:apply-templates select="d:*"/>
              <xsl:apply-templates select=".//wadl:method"/>
            </div>
          </xsl:template>

  <!-- toc mode -->
  <xsl:template match="d:preface|d:chapter" mode="toc">
    <li><a href="#{@xml:id}"><xsl:value-of select="translate(d:title,' ','&#160;')"/></a></li>
    <li class="divider"></li>
  </xsl:template>

  <xsl:template match="@*|node()" mode="toc">
    <xsl:apply-templates mode="toc"/>
  </xsl:template>
  <!-- end toc mode -->

        <xsl:template match="wadl:method">
          <xsl:variable name="id"><xsl:value-of select="generate-id()"/></xsl:variable>
          <xsl:variable name="skipNoRequestTextN">0</xsl:variable>
          <xsl:variable name="skipNoRequestText" select="boolean(number($skipNoRequestTextN))"/>
          <xsl:variable name="skipNoResponseTextN">0</xsl:variable>
          <xsl:variable name="skipNoResponseText" select="boolean(number($skipNoResponseTextN))"/>
          <div class="doc-entry">
            <div class="row {$id}">
              <div class="col-md-1">
                <span class="label label-success"><xsl:value-of select="@name"/></span>
              </div>
              <div class="col-md-5">
                <xsl:value-of select="replace(replace(ancestor::wadl:resource/@path, '\}','}&#8203;'), '\{','&#8203;{')"/>
              </div>
              <div class="col-md-5">
                <xsl:choose>
                  <xsl:when test="wadl:doc//d:*[@role = 'shortdesc'] or wadl:doc//xhtml:*[@class = 'shortdesc']">
                    <xsl:apply-templates select="
                      wadl:doc/xhtml:p[@class='shortdesc']|
                      wadl:doc/d:para[@role = 'shortdesc']|
                      wadl:doc//xhtml:span[@class='shortdesc']|
                      wadl:doc//d:phrase[@role = 'shortdesc']
                      "/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="
                      wadl:doc/xhtml:*|
                      wadl:doc/d:*|
                      wadl:doc/text()
                      "/>
                  </xsl:otherwise>
                </xsl:choose>&#160;
              </div>
              <div class="col-md-1">
                <button class="btn btn-info btn-sm btn-detail" id="detail-{$id}-btn" data-toggle="collapse" data-target="#detail-{$id}">detail</button>
              </div>
            </div>
            <div class="row collapse api-detail" id="detail-{$id}">
              <div class="col-md-12">
                <div>
                  <!-- Description of method -->
                  <xsl:if test="wadl:doc//d:*[@role = 'shortdesc'] or wadl:doc//xhtml:*[@class='shortdesc']">
                    <xsl:apply-templates
                        select="wadl:doc/d:*[not(@role = 'shortdesc')]|wadl:doc/xhtml:*[not(@role = 'shortdesc')]"/>
                  </xsl:if>
                </div>
                <!-- process response codes -->
                <xsl:if
                    test="wadl:response[starts-with(normalize-space(@status),'2') or starts-with(normalize-space(@status),'3')]">

                  <!-- Don't output if there are no status codes -->
                  <div class="row">
                    <div class="col-md-3">
                      <b>Normal Response Codes</b>
                    </div>
                    <div class="col-md-9">
                      <xsl:apply-templates
                          select="wadl:response" mode="preprocess-normal"/>
                    </div>
                  </div>
                </xsl:if>
                <xsl:if
                    test="wadl:response[not(starts-with(normalize-space(@status),'2') or starts-with(normalize-space(@status),'3'))]">

                  <div class="row">
                    <div class="col-md-3">
                      <b>Error Response Codes</b>
                    </div>
                    <div class="col-md-9">
                      <xsl:apply-templates
                          select="wadl:response[not(@status)]"
                          mode="preprocess-faults"/>
                      <xsl:apply-templates select="wadl:response[(@status)]"
                                           mode="preprocess-faults"/>
                    </div>
                  </div>
                </xsl:if>
                <div class="row">
                  <div class="col-md-12">
                    <!-- Don't output if there are no params -->
                    <xsl:if test="./wadl:request//wadl:param or parent::wadl:resource/wadl:param">
                      <b>Request parameters</b>
                      <table class="table table-bordered table-striped">
                        <thead>
                          <tr>
                            <th>Parameter</th>
                            <th>Style</th>
                            <th>Type</th>
                            <th>Description</th>
                          </tr>
                        </thead>
                        <tbody>
                          <xsl:apply-templates select="./wadl:request//wadl:param|parent::wadl:resource/wadl:param"
                                               mode="param2tr">
                            <!-- Add templates to handle wadl:params -->
                            <xsl:with-param name="id" select="$id"/>
                          </xsl:apply-templates>
                        </tbody>
                      </table>
                    </xsl:if>


                    <!-- Don't output if there are no params -->
                    <xsl:if test="./wadl:response//wadl:param">
                      <b>Response parameters</b>
                      <table class="table table-bordered table-striped">
                        <thead>
                          <tr>
                            <th>Parameter</th>
                            <th>Style</th>
                            <th>Type</th>
                            <th>Description</th>
                          </tr>
                        </thead>
                        <tbody>
                          <xsl:apply-templates select="./wadl:response//wadl:param" mode="param2tr">
                            <!-- Add templates to handle wadl:params -->
                            <xsl:with-param name="id" select="$id"/>
                          </xsl:apply-templates>
                        </tbody>
                      </table>
                    </xsl:if>


                  </div>
                </div>
                <!-- Examples -->
                <xsl:choose>
                  <xsl:when
                      test="wadl:request/wadl:representation[ends-with(@mediaType,'/xml') ]/wadl:doc//xsdxt:code
                              and wadl:request/wadl:representation[ends-with(@mediaType,'/json')]/wadl:doc//xsdxt:code">
                    <div class="row">
                      <div class="col-md-3">
                        <select class="example-select form-control">
                          <option data-target="#req-json-{$id}" value="json" selected="selected">JSON Request</option>
                          <option data-target="#req-xml-{$id}" value="xml">XML Request</option>
                        </select>
                      </div>
                    </div>
                    <div class="tab-content">
                      <div class="tab-pane example active" id="req-json-{$id}">
                        <xsl:apply-templates
                            select="wadl:request/wadl:representation[ends-with(@mediaType,'/json') ]/wadl:doc//xsdxt:code"/>
                      </div>
                      <div class="tab-pane example" id="req-xml-{$id}">
                        <xsl:apply-templates
                            select="wadl:request/wadl:representation[ends-with(@mediaType,'/xml') ]/wadl:doc//xsdxt:code"/>
                      </div>
                    </div>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="wadl:request/wadl:representation/wadl:doc//xsdxt:code"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                  <xsl:when
                      test="wadl:response/wadl:representation[ends-with(@mediaType,'/xml') ]/wadl:doc//xsdxt:code
                        and wadl:response/wadl:representation[ends-with(@mediaType,'/json')]/wadl:doc//xsdxt:code">
                    <div class="row">
                      <div class="col-md-3">
                        <select class="example-select form-control">
                          <option data-target="#resp-json-{$id}" value="json" selected="selected">JSON Response</option>
                          <option data-target="#resp-xml-{$id}" value="xml">XML Response</option>
                        </select>
                      </div>
                    </div>
                    <div class="tab-content">
                      <div class="tab-pane example active" id="resp-json-{$id}">
                        <xsl:apply-templates
                            select="wadl:response/wadl:representation[ends-with(@mediaType,'/json') ]/wadl:doc//xsdxt:code"/>
                      </div>
                      <div class="tab-pane example" id="resp-xml-{$id}">
                        <xsl:apply-templates
                            select="wadl:response/wadl:representation[ends-with(@mediaType,'/xml') ]/wadl:doc//xsdxt:code"/>
                      </div>
                    </div>


                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="wadl:response/wadl:representation/wadl:doc//xsdxt:code"/>
                  </xsl:otherwise>
                </xsl:choose>

                <!-- we allow no response text and we dont have a 200 level response with a representation -->
                <xsl:choose>
                  <xsl:when
                      test="not(wadl:request) and not(wadl:response[starts-with(normalize-space(@status),'2')]/wadl:representation)">
                    <xsl:copy-of select="$wadl.noreqresp.msg"/>
                  </xsl:when>
                  <xsl:when test="not(wadl:request)">
                    <xsl:copy-of select="$wadl.norequest.msg"/>
                  </xsl:when>
                  <xsl:when test="not(wadl:response[starts-with(normalize-space(@status),'2')]/wadl:representation)">
                    <xsl:copy-of select="$wadl.noresponse.msg"/>
                  </xsl:when>
                </xsl:choose>

              </div>
            </div>
          </div>
          <xsl:text></xsl:text>
        </xsl:template>

          <xsl:template match="wadl:doc|wadl:resource|wadl:link">
            <xsl:apply-templates/>
          </xsl:template>

          <xsl:template match="wadl:doc[parent::wadl:resource]"/>

          <xsl:template match="d:para">
            <p><xsl:apply-templates/></p>
          </xsl:template>

          <xsl:template match="d:link" xmlns:xlink="http://www.w3.org/1999/xlink">
            <a href="{@xlink:href}"><xsl:apply-templates/></a>
          </xsl:template>
          <xsl:template match="d:programlisting">
            <pre><xsl:apply-templates/></pre>
          </xsl:template>

          <xsl:template match="d:title[parent::d:chapter or parent::d:section or parent::d:book]|d:info|wadl:param"/>

          <xsl:template match="d:example/d:title">
            <b><xsl:apply-templates/></b>
          </xsl:template>

          <xsl:template match="d:example|xsdxt:code">
            <div class="example">
              <xsl:apply-templates/>
            </div>
          </xsl:template>

          <xsl:template match="d:itemizedlist">
            <ul>
              <xsl:apply-templates/>
            </ul>
          </xsl:template>

          <xsl:template match="d:orderedlist">
            <ol>
              <xsl:apply-templates/>
            </ol>
          </xsl:template>

          <xsl:template match="d:listitem">
            <li>
              <xsl:apply-templates/>
            </li>
          </xsl:template>

          <xsl:template match="wadl:param" mode="param2tr">
            <tr>
              <td><xsl:value-of select="@name"/><xsl:if test="not(@required = 'true') and not(@style = 'template') and not(@style = 'matrix')"> (Optional)</xsl:if></td>
              <td><xsl:value-of select="if(@style = 'template') then 'URI' else @style"/></td>
              <td><xsl:value-of select="if(not(@type) or @type = '') then 'String' else @type"/></td>
              <td><xsl:apply-templates select="./wadl:doc/*|./wadl:doc/text()"/></td>
            </tr>
          </xsl:template>

          <xsl:template match="d:code"><code><xsl:apply-templates/></code></xsl:template>
          <xsl:template match="d:*">
            <xsl:copy>
              <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
          </xsl:template>

  <xsl:template name="trimUri">
    <!-- Trims elements -->
    <xsl:param name="trimCount"/>
    <xsl:param name="uri"/>
    <xsl:param name="i">0</xsl:param>
    <xsl:choose>
      <xsl:when test="$i &lt; $trimCount and contains($uri,'/')">
        <xsl:call-template name="trimUri">
          <xsl:with-param name="i" select="$i + 1"/>
          <xsl:with-param name="trimCount">
            <xsl:value-of select="$trimCount"/>
          </xsl:with-param>
          <xsl:with-param name="uri">
            <xsl:value-of select="substring-after($uri,'/')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('/',$uri)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
          <xsl:template match="wadl:response" mode="preprocess-normal">
            <xsl:variable name="normStatus" select="normalize-space(@status)"/>
            <xsl:if
              test="starts-with($normStatus,'2') or starts-with($normStatus,'3')">
              <xsl:call-template name="statusCodeList">
                <xsl:with-param name="codes" select="$normStatus"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:template>

          <xsl:template match="wadl:response" mode="preprocess-faults">
            <xsl:if
              test="(not(@status) or not(starts-with(normalize-space(@status),'2') or starts-with(normalize-space(@status),'3')))">
              <xsl:variable name="codes">
                <xsl:choose>
                  <xsl:when test="@status">
                    <xsl:value-of select="normalize-space(@status)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="'400 500 &#x2026;'"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="wadl:representation/@element">
                  <xsl:variable name="statusCodes">
                    <xsl:call-template name="statusCodeList">
                      <xsl:with-param name="codes" select="$codes"/>
                      <xsl:with-param name="inError" select="true()"/>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:value-of
                    select="substring-after((wadl:representation/@element)[1],':')"
                  /> (<xsl:value-of select="normalize-space($statusCodes)"/>)</xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="statusCodeList">
                    <xsl:with-param name="codes" select="$codes"/>
                    <xsl:with-param name="inError" select="true()"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="following-sibling::wadl:response">
                  <xsl:text>,&#x0a;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>&#x0a;</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </xsl:template>


          <xsl:template name="statusCodeList">
            <xsl:param name="codes" select="'400 500 &#x2026;'"/>
            <xsl:param name="separator" select="','"/>
            <xsl:param name="inError" select="false()"/>
            <xsl:variable name="code" select="substring-before($codes,' ')"/>
            <xsl:variable name="nextCodes"
              select="substring-after($codes,' ')"/>
            <xsl:choose>
              <xsl:when test="$code != ''">
                <xsl:call-template name="statusCode">
                  <xsl:with-param name="code" select="$code"/>
                  <xsl:with-param name="inError" select="$inError"/>
                </xsl:call-template>
                <xsl:text>, </xsl:text>
                <xsl:call-template name="statusCodeList">
                  <xsl:with-param name="codes" select="$nextCodes"/>
                  <xsl:with-param name="separator" select="$separator"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="statusCode">
                  <xsl:with-param name="code" select="$codes"/>
                  <xsl:with-param name="inError" select="$inError"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:template>
          <xsl:template name="statusCode">
            <xsl:param name="code" select="'200'"/>
            <xsl:param name="inError" select="false()"/>
            <xsl:choose>
              <xsl:when test="$inError">
                <errorcode>
                  <xsl:value-of select="$code"/>
                </errorcode>
              </xsl:when>
              <xsl:otherwise>
                <returnvalue>
                  <xsl:value-of select="$code"/>
                </returnvalue>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:template>
        </xsl:stylesheet>