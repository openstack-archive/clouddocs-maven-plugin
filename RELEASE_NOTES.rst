Release Notes
=============

clouddocs-maven-plugin 2.1.3 (Sept. 22, 2014)
============================================================
- Features and updates

   - Add the title of the service for each API call in API Reference pages
   - Support YAML syntax highlighting

-  Bug fixes

   -  CSS fixes for Rackspace output
   - Minor improvements for developers working on the plugin itself
   - Updates to Rackspace-branded output
   - Allow an error phrase to be listed with the response code for API deliverables
   - Use roman page numbers for preface

clouddocs-maven-plugin 2.1.2 (July 15, 2014)
============================================================
-  Features and updates

   -  Add hyphenation support for FOP
   -  Use new logo in Rackspace output

-  Bug fixes

   -  Fix incorrect link in Rackspace API reference

clouddocs-maven-plugin 2.1.1 (June 30, 2014)
============================================================
-  Features and updates

   -  Depend on latest version of wadl-tools (1.0.27).

-  Bug fixes

   -  Avoid duplicating method content from included wadl when the included method appears more than once.
   -  New header etc in Rackspace branded api reference page.
   -  Avoid spurious "No body required" text in guides generated from wadl.
   -  Fix font bug in generate-pdf goal.
   -  Use refactored wadl-processing code for api-reference page to cause all parameters to appear.

clouddocs-maven-plugin 2.1.0 (June 23, 2014)
============================================================
-  Features and updates

   -  Support fixing xml:id, linkend, and xlink:href attributes when xincluding content more
      than once. For more information, see https://github.com/docbook/transclusion-fixup and
      http://docbook.org/docs/transclusion/2010-12-09/transclusion.html#d6e179

clouddocs-maven-plugin 2.0.4 (June 05, 2014)
============================================================
-  Bug fixes

   -  Rackspace branding, Webhelp: Add <noscript> bar encouraging users to enable JavaScript.
   -  Rackspace branding: Minor change to copyright statement.
   -  Rackspace branding, Webhelp: Remove tealium js because this is now pulled in via HaaS.

clouddocs-maven-plugin 2.0.3 (May 22, 2014)
============================================================
-  Bug fixes

   -  Support nested bold and italic text in code listings with syntax highlighting.
   -  Support arbitrary legalnotice text and inject appropriate text when role="rpc".

clouddocs-maven-plugin 2.0.2 (May 09, 2014)
============================================================
-  Bug fixes

   -  OpenStack branding: Do not default builtForOpenStack to 1 when branding = openstack. These are independent parameters.
   -  OpenStack branding: Apply css to glossterms even in admonitions.
   -  Rackspace branding: set debug=false in Header-as-a-Service call.
   -  Rackspace branding: Fix bug where toc overlapped the content pane if the cookie had not been set yet.

clouddocs-maven-plugin 2.0.1 (May 07, 2014)
============================================================
-  Bug fixes

   -  For Rackspace branding, use the favicon.ico from a CDN.
   -  For Rackspace branding, align search results to the left.
   -  For OpenStack branding, make varlistentry/terms bold.
   -  Avoid invalid ids <a> tags created from glossterms.

clouddocs-maven-plugin 2.0.0 (April 23, 2014)
============================================================
-  Features and updates

   -  Backwards incompatible change for Rackspace branding only: Update Rackspace webhelp format to use header-as-a-service and feedback-as-a-service. OpenStack branding unchanged.
   -  Add PDF link on API site pages.

-  Bug fixes

   -  Use "Powered by OpenStack" logo in webhelp for Rackspace Private Cloud branding.
   -  Remove spurious backslash from Google Analytics js.
   -  Cosmetic improvements to overview pages for OpenStack api-site.

clouddocs-maven-plugin 1.15.0 (March 21, 2014)
============================================================
-  Features and updates

   -  Support <branding> parameter for api-ref pages (openstack and rackspace supported)
   -  Support bodyFont, monospaceFont, and localFontPath parameters to provide alternate fonts used when generating pdfs.
   -  Add Tealium utag.js to html output when branding = rackspace.

-  Bug fixes

   -  Address Launchpad #1289568 which caused processing to fail on certain wadls.
   -  Revert change which made the shortdesc line appear as the first line in the body of the api reference sections.
   -  Fix NPE when using generate-pdf and generate-html goals.

clouddocs-maven-plugin 1.14.1 (March 5, 2014)
============================================================
-  Bug fixes

   -  Address https://bugs.launchpad.net/openstack-manuals/+bug/1288395

clouddocs-maven-plugin 1.14.0 (March 3, 2014)
============================================================
-  Features and updates

   -  Generate wadl and json representations of the API in the content directory. Using new wadl-tools version.
   -  Support adding an xml:id attribute to the wadl:resources element in the DocBook content that will make the resulting section URIs unique.
   -  For Rackspace branding, use new copyright format.
   -  In content generated from wadl, no longer suppress content marked role="shortdesc" from the method docs.
   -  Apiref output: Automatically generate the toc content.
   -  Apiref output: Support Google Analytics parameters.
   -  Webhelp output: Support using path delimiters in webhelpDirname parameter.
   -  Webhelp output: Turn off social icons when branding is set to rackspace.

-  Bug fixes

   -  Support automatically adding "No request body required" and "No response body required" text for JSON bodies.
   -  Fix bug resulting in spurious "SEVERE: Image not available." messages on stdout.
   -  In the generated wadl reference, add a leading / to the URI if necessary.
   -  Fix bug where search highlighting interfered with syntax highlighting.
   -  Fix bug resulting in empty <b/> elements before sidebar/title elements.

clouddocs-maven-plugin 1.13.0 (January 23, 2014)
============================================================
-  Features and updates

   -  Move method signatures back to the top of methods in generated API reference for guides.
   -  Add hyperlinks from summary tables to method reference pages in generated API reference for guides.
   -  Add support for a Rackspace Private Cloud branding.

-  Bug fixes

   -  Improve handling of paths containing spaces.
   -  Provide more information in certain error states.
   -  Support <part>s in pdf and webhelp output.
   -  Support the glossaryCollection parameter for pdfs automatically generated during webhelp build.
   -  Improve formatting of paths in sections generated for API references in guides.

clouddocs-maven-plugin 1.12.2 (January 8, 2014)
============================================================
-  Bug fixes

   -  Minor update to OpenStack API Reference page.

clouddocs-maven-plugin 1.12.1 (January 7, 2014)
============================================================
-  Features and updates

   -  Updates to OpenStack API reference page
   -  In reference pages generated from wadl, format paths according to RFC 6570.

-  Bug fixes

   -  Fix bug where resource titles were omitted when using point-to-wadl
   -  Avoid duplicate ids when combining several wadls into one doc by including rax:id from resources in generated section id.
   -  Do not output section title on the index.html page.
   -  Updates to response code text generated by xslts.

clouddocs-maven-plugin 1.12.0 (November 19, 2013)
============================================================
-  Features and updates

   -  Support @url attribute on raxm:product for publishing several version of the same document.
   -  Depend on version 1.0.19 of wadl-tools.
   -  Remove Coremetrics Javascript from webhelp.
   -  Format <parameter> element as monospace instead of italics.
   -  In reference content generated from wadl files:

      -  Change "Verb" to "Method" in summary tables.
      -  Modify the appearance of "Required" and "Optional" in parameter tables.
      -  Format response codes in a table if descriptions are available.
      -  Format plain parameters for JSON bodies as a tree with collapsible nodes.
      -  Fix regression where override of the titles for body examples were not respected.

-  Bug fixes

   -  Fix XSS vulnerabilities in Webhelp output.
   -  Fix bug where webhelpBasename wasn't respected for .war file names.
   -  Eliminiate various xsl errors when multiple raxm:metadata/* elements appear in the document.
   -  Avoid xslt errors when inline markup stripped from code listings had attributes.



clouddocs-maven-plugin 1.11.1 (October 14, 2013)
============================================================
-  Bug fixes

   -  Hide "Log a Bug" link at bottom of page in Rackspace output.
   -  Updated apipage-main.xsl to include metering API
   -  Updated Rackspace logo
   -  Fix alignment of ordered lists in API reference pages.
   -  Rename "Template" parameters as "URI" parameters in output.

clouddocs-maven-plugin 1.11.0 (September 30, 2013)
============================================================
-  Add "Log a bug" link to OpenStack output.
-  Moving to Maven Central
-  Bug fixes

   -  Empty Request or Response sections sometimes created if an incomplete wadl was processed.
   -  Reduce noise on stdout and improve ability to debug XProc pipelines (when run with --debug)
   -  Use Calabash 1.0.13-94 for XProc piplines.
   -  In api-ref page xslts, adjust xpath expressions to account for changes in wadl-tools.
   -  Add missing <th>s to param tables in api reference output.


clouddocs-maven-plugin 1.10.0 (September 17, 2013)
============================================================
-  New formatting for api-ref.html output
-  Refactored API reference page layout to include plain parameters and longform doc of media type.
-  Bug fixes

   - Fixed "Failed to load image" messages from DocBook xsls on stdout.
   - Fixed invalid css rules.
   - Generate table from plain parameters when documenting requests/response and no longer suppress documentation related to code samples embedded with requests/responses in wadls.
   - Show error codes in apiref.html output.
   - No longer include timestamp in file names for intermediate invalid file generated in target directory.
   - Fixed bug where it was impossible to refer to a wadl by URL.
   - Refactored wadl2docbook code for improved readability.


clouddocs-maven-plugin 1.9.3 (September 5, 2013)
============================================================
-  Bug fixes:

   - Fix encoding issues that prevented building the plugin on Windows.
   - Fix path issues that prevented building documents on Windows.
   - Fix issue where documents would not build with a space in the path.
   - Add zero-width spaces after underscore characters in template paramters in the api-ref.html output to allow for wrapping of long paths.
   - Use https:// to refer to eluminate.js to avoid long loads when loading from file system in some browsers.

clouddocs-maven-plugin 1.9.2 (August 19, 2013)
============================================================
-  Bug fixes:

   - Improve presentation of informaltables and CALS tables generally.
   - Format <replaceable> as italic inside screen, programlisting, and literallayout.

clouddocs-maven-plugin 1.9.1 (August 15, 2013)
============================================================
-  Support language="ini" for syntax highlighting on code listings.

clouddocs-maven-plugin 1.9.0 (August 13, 2013)
============================================================
-  Added support for olinks and the olink-maven-plugin.

   - By default, the olink database is assumed to be in target/olink.db.
   - olinks to the same document are converted to xrefs.
   - Currently, olinks are never hot.
-  Change the presentation of dates in pdf and webhelp so that the full month name is used.
-  Add param style and type to tables in apiref page.
-  It is now possible to filter wadl content using the security attribute. Note that in the wadl the security attribute must be in the DocBook namespace. For example declare xmlns:db="http://docbook.org/ns/docbook" on the root element and then put the db:security on any element (for example, a method).
-  You can now add role="hidden" on the rax:metadata element to cause the document not to appear on the docs.rackspace.com landing page.
-  Add support for Japanese fonts in pdfs.
-  Bug Fixes:
   - Be consistent about wrapping wadl:doc contents in paras even if it contains inline markup.
   - Support book/info/title when generating atom.xml.

clouddocs-maven-plugin 1.8.0
============================================================
-  Improvements to the api reference output: floating toc and anchors for each heading.
-  Support support for additional DocBook params: pageWidth, pageHeight, doubleSided, and omitCover so OpenStack can use it for their ops guide.
-  Improve formatting of tables by adding rules="all" if not there already.
-  Fixed formatting of variablelists in html output
-  Depend on latest version of wadl-tools

clouddocs-maven-plugin 1.7.2
============================================================
-  Support building docs on Windows.
-  Depend on latest version of wadl-tools, 1.0.12
-  Bug fixes:

   - When producing documentation from WADL, do not list 3xx responses as error codes.
   - Do build-time search-and-replace AFTER resolving wadls so search-and-replace works on wadl-genereated content.
   - Left-align table titles for html tables

clouddocs-maven-plugin 1.7.1 (February 19, 2013)
============================================================
-  Support pdfFilenameBase parameter. Use this parameter to provide an alternative name for the pdf automatically generated when producing webhelp output. By default the base name of the pdf is the base name of the input xml file.
-  Support webhelpDirname parameter. Use this parameter to provide an alternative name for the generated webhelp directory. By default the name of the webhelp output directory is the base name of the input xml file.
-  Support targetDirectory parameter. Use this parameter to control where the output lands (i.e. instead of target/docbkx/webhelp).
-  Bug fixes:

   - Only include Google Analytics and social icons if security = external.
   - Set section.label.includes.component.label to one only if section.autolabel=1.
   - Fixed bug where auto-image copy failed if there was a trailing space in the value of the fileref attribute.
   - Fixed bug where linefeeds within a glossterm prevented autoglossary from matching term with basename.
   - Removed IE=7 meta tag from webhelp because it was causing Disqus not to work.

clouddocs-maven-plugin 1.7.0 (January 13, 2013)
============================================================
-  Support publicationNotificationEmails parameter. A comma-delimited list of email addresses to which emails are sent when the document is publised.
-  Support includeDateInPdfFilename parameter. Set this paremeter to 0 to prevent the date from being appended to the pdf file name.
-  Autofill pubdate with current date if it is empty.
-  When a file is invalid, put a copy of the validated file in target dir named something like: basefilename.xml-invalid-date.xml
-  Use latest version of wadl-tools
-  Bug fixes:

   - Make it possible to pass in statusBarText from pom or command line.
   - Reduce padding between admon title and first para in webhelp output.
   - Omit pubdate from pdf file name when branding is openstack.
   - Don't keep param tables together in wadl2docbook generated xml to avoid having long tables be mutilated.
   - Fix bug where PdfBuilder uses wrong source file for cover info.
   - Avoid "The value of param status.bar.text must be a valid Java Object" errors.
   - Support sectionLabelIncludesComponentLabel in autopdf.
   - Pass in fully qualified path to webhelp output dir to bookinfo.xsl so that it will put bookinfo.xml and bookinfo.properties in the correct place even if you do "mvn -f path/to/pom.xml".
   - Fix bug where a sequence was used as first arg of substring-after when a response has more than one representation/element.

clouddocs-maven-plugin 1.6.1 (November 27, 2012)
============================================================
-  Bug fix release:

   - Fix bug where appendix.autolabel wasn't being passed in to auto-generated pdfs from pom.
   - Fix bug where xslts weren't found in the target directory when building doc from a parent pom.
   - Fix problem where wadls weren't found if referred to as href="filename.wadl". Must be href="./filename.wadl". Have xsl prepend ./ when needed.
   - Wadl processing: Avoid "7th argument of concat cannot be a sequence" error which happens when you have a response with multiple representation/@element nodes.

clouddocs-maven-plugin 1.6.0 (November 10, 2012)
============================================================

-  Automatically handle images:

   -  Detects if images are missing from a document and fail if an
      image is missing. You can turn off this validation by setting
      <strictImageValidation>false</strictImageValidation> in your
      pom.xml.
   -  For Webhelp output, automatically converts .svg to .png.
   -  Automatically copies images to the Webhelp output directory.

-  Automatically build pdf when building webhelp and copy pdf to
   webhelp directory unless <makePdf>false</makePdf> is set in your
   pom.xml.

   -  Generate pdf file names in the format basename-20121110.pdf where
      basename is the base pdf name and 20121110 is the taken from
      /*/info/pubdate in the document. If the pdf is generated with a
      security value other than external, then put the security value
      in the pdf file name. For example,
      basename-internal-20121110.pdf.
   -  For Rackspace branding, by default the link to the pdf is
      changed to basename-latest.pdf to provide a permalink to the
      latest pdf. Our landing page dynamically redirects to the file
      name of the current pdf. To avoid this behavior and have the pdf
      link in webhelp be to the actual pdf, set \
      <useLatestSuffixInPdfUrl>0</useLatestSuffixInPdfUrl>.

-  Provide better error messages if incorrect DocBook version is used
   (i.e. if DocBook 4.x is used instead of 5.x).
-  Updated Rackspace logo.
-  Move profiling to early in the pipeline. This fixes bugs where
   content in title and revhistory weren't being profiled.
-  Fix bug where IDREFs weren't validated.
-  Support passing in -Dsecurity=internal|external|reviewer and
   -Ddraft.status=on|off from the command line.
-  Generate .war file version of webhelp with bookinfo.xml file to
   support autopublish to landing page. To generate a war you must set
   webhelp.war. Typically this will be done from the Jenkins job that
   builds for autopublishing (-Dwebhelp.war=1).
-  It is no longer necessary to add ids to every <resource> in a wadl
   to use the point-to-wadl method of including content from a wadl.
-  Validation changes:

   -  Documents are now validated twice. Post xinclude, the documents
      are validated without checking IDREF integrity. Documents are
      validated again after wadl inclusion. At this time IDREFs are
      checked.
   -  When a validation error is detected, a copy of the invalid
      document is now stored in the /tmp directory with a name like
      /tmp/invalid-2012-10-14T11:21:14.913-05:00.xml

- Generate war version of Webhelp output when webhelp.war=1.
- Added support for a Repose branding (see http://openrepose.org/).
- Bugfix: In PDF output, quote chapter names instead of italicizing them.
- Bugfix: IDREFs are validated now during the build.

clouddocs-maven-plugin 1.5.0 (November 6, 2012)
============================================================
-  Improve the way Google Analytics is called.

clouddocs-maven-plugin 1.5.0 (August 14, 2012)
============================================================
-  Support build-time search and replace via a configuration file. To
   use add a parameter like the following to your pom.xml:
   <replacementsFile>replacements.config</replacementsFile> Where
   replacements.config is a file in the same directory as your
   pom.xml. See the example replacements.config file for documentation
   on how to use it.

clouddocs-maven-plugin 1.4.0 (August 13, 2012)
============================================================
- Chinese fonts now supported in pdf output.
- WADL2DocBook: Fixed bug where query params were copied down the WADL
  tree.
- Removed reference to tabpress.com js file which was not loading
  causing pages not to load. Unfortunately, this disables all social
  icons for now.
- Added support for a secondaryCoverLogoPath param that allows the
  user to specify a second logo that appears on the bottom left of the
  pdf.
- Fixed bug where cross-references were not resolved correctly in the
  revision history table.
- Fixed bug where parameters were omitted in some cases.

clouddocs-maven-plugin 1.3.1 (May 30, 2012)
============================================================

New features and changes
------------------------

-  You can now control the size of the status bar text:
   ``<?rax status.bar.text.font.size="50px" status.bar.text="LIMITED AVAILABILITY"?>``.
   The default size of the text is about 71.3px, so if you need it
   smaller go from there. 50px should work for "LIMITED AVAILABILITY".
-  When generating DocBook from wadl, if you spin as
   <security>writeronly</security>, at the top of each generated section
   it shows what wadl the method came from and what the method id is.
-  You no longer need to pre-normalize wadls when using wadl2docbook.
-  Added css rules to hide sidebar automatically when printing web page.

Bug fixes
---------
-  Fixed bug in extensions doc mechanism where wadl urls weren't picked
   up from info/extensions metadata.
-  Fixed bug where syntax highlighter padded spaces with &nbsp;s which
   would break XML when cut and pasted since nbsp isn't interpreted as
   a space character.
-  Enabled automatic glossary generation for pdfs.
-  Fixed the generation of ids on generated wrapper sections in
   wadl2docbook.
-  In certain cases, code listings with callouts had extra line breaks
   added.
-  The feature that automatically keeps short code listings together
   was not working.
-  When you clicked on a link to an anchor within a page, the heading
   was partially hidden by the banner.


clouddocs-maven-plugin 1.2.0 (April 26, 2012)
=============================================

Bug fixes
---------

-  Bug fixes in syntax highlighting:

   -  Now support manually inserted <co> style callouts.
   -  Now support markup inside programlistings, etc.
   -  Added "Select" button to code listing to make it easier to know
      how to select the code sample.
   -  JavaScript files only loaded when used and consolidated into a
      single file.
   -  Adjusted formatting to avoid problems when many callouts appear in
      one listing.

-  Webhelp

   -  Fix bug where searches with quotes return no results.

   -  Don't put border around footer table if footer navigation is
      enabled.

-  Wadl2DocBook: Fix the generation of ids for sections generated from
   wadl methods.


clouddocs-maven-plugin 1.1.0 (March 30, 2012)
=============================================

New features and changes
------------------------

-  Syntax highlighting and line numbering for code samples for supported
   languages (bash, xml, json, javascript, json, and others to be
   added).

   -  Use the language attribute on the programlisting, literallyout,
      and screen to indicate the programming language used in the code
      sample. Supported languages currently include:

      -  bash
      -  xml
      -  javascript
      -  json
      -  python
      -  java

-  Extensions documents are automatically generated when extensions
   information is included in the book/info element.

   -  An example of how to use this feature is available in the
      following pull request
      `https://github.com/RackerWilliams/rax-compute-extensions/pull/1 <https://github.com/RackerWilliams/rax-compute-extensions/pull/1>`_

-  The target of the "Legal notices" link is now configurable so that
   the user can set the ``legalNoticeUrl`` parameter in the pom.
-  The socialIcons parameter is now tied to the security parameter so
   that it is impossible to generate a document that is both internal
   and contains socialIcons.

Bug fixes
---------

-  Fixed bug where the title in webhelp was incorrect when a doc
   contained multiple releaseinfo elements.
-  Fixed bug where doc builds failed when using maven 2.
-  Fixed bug where pdfs were missing images in some cases.

clouddocs-maven-plugin 1.0.11 (02 February 2012)
================================================

New features and changes
------------------------

-  Automatically keep together short ``programlisting``s.

-  Documents are validated before processing and the build fails if the
   document is invalid. If you would like to build even with an invalid
   document, set ``<failOnValidationError>no</failOnValidationError>``
   in your ``pom.xml``.
-  Add <showXslMessages>true</showXslMessages> to your pom.xml to see
   useful error messages from Maven.
-  Added generate-html goal to generate API reference page for
   OpenStack: `http://api.openstack.org/ <http://api.openstack.org/>`_
-  Support <builtForOpenStack>1</builtForOpenStack> param to add logo on
   cover of pdf.
-  Support the following params for alternative branding:

   -  coverLogoPath: Path, relataive to the pom.xml, for an alternative
      logo.

   -  coverLogoLeft: Distance from the left edge of the page where the
      logo should be placed (e.g. 4in)

   -  coverLogoTop: Distance from the top of the page where the logo
      should be placed (e.g. 8in)
   -  coverUrl: Url to use beneath the logo (e.g. docs.example.com)

   -  coverColor: Color to for the polygon on the cover that is usually
      red. RGB hex value (e.g. c42126)

Bug fixes
---------

-  wadl-tools bug fixes:

   -  `https://github.com/rackspace/wadl-tools/pull/17 <https://github.com/rackspace/wadl-tools/pull/17>`_

-  <emphasis role="italics"> (what you get when you click the Italic
   button in Oxygen) now produces italics in webhelp (it was already
   doing the right thing in pdf).
-  Adjusted handling of <sidebar> element in pdf and html.

clouddocs-maven-plugin 1.0.10 (09 February 2012)
================================================

New features and changes
------------------------

-  Adjusted wadl2docbook processing so that "This operation does not
   require a request body." messages will appear in the output even if
   there is a code sample as long as there is no element attribute on
   the representation with a mediaType of application/xml. Request from
   Mike Asthalter.
-  The clouddocs plugin now uses the wadl xsls from wadl-tools.
-  New parameter ``metaRobots`` adds
   ``<meta name="robots" content="NOINDEX, NOFOLLOW"/>`` to webhelp.
   This is so that writers can publish private beta docs on
   docs.rackspace.com and avoid having them indexed by spiders.
-  Social icons feature now logs clicks to Google Analytics.

Bug fixes
---------

-  Fixed bug where glossary terms containing spaces did not receive
   working tool tips.
-  Fixed wadl normalizer bug where params weren't appearing in output.
-  Fixed wadl normalizer bug where invalid wadls were produced if the
   path attribute on a resource begins with a / character.
-  Fixed wadl normalizer bug where extension attributes and elements
   weren't copied when the wadl was normalized into tree-format.
-  Fixed bug where content flagged as internal in revhistory might
   escape into atom.xml
-  Fixed bug where certain terms do not appear in search results.

clouddocs-maven-plugin 1.0.9 (03 January 2012)
==============================================

New features and changes
------------------------

-  Support for Twitter, Facebook, and Google+ icons in webhelp. Turn
   these on with the ``<socialIcons>1</socialIcons>`` parameter in your
   ``pom.xml``.
-  In WADL normalizer, a new switch allows you to omit resource\_type
   elements and links to them ( -r keep, the default, or -r omit in the
   script or via the xslt parameter resource\_types, set to "keep" or
   "omit", where keep is the default).

Bug fixes
---------

-  Eliminated 'table-layout="auto" not supported' error messages from
   the Maven plugin.
-  Eliminated spurious "Failed to load image" error messages from the
   Maven plugin.
-  Changed the vertical alignment of the date column of the revision
   history table to top.
-  Add background shading to <screen> element.
-  Wadl formatting fixes:

   -  Query parameters no longer appear in the URI in the summary tables
      (to reduce clutter). Only in the actual reference page.
   -  Zero-width spaces are inserted programmatically into type names
      Type column of parameter table to cause them to wrap without a
      hyphen.

-  Wadl normalizer fixes:

   -  Copy \_all\_ namespace declarations to root element of wadl.
   -  Corrected handling of elements when a mixed tree/path formatted
      wadl is converted to a tree formatted wadl

-  Improved error messages when an incorrect date format is used (e.g.
   in releaseinfo)
-  No longer show ``<revhistory>`` at the top of articles (or when doc
   is rooted at any other element)
-  Format guibutton, guiicon, guilabel, guimenu, guimenuitem, and
   guisubmenu as bold.
-  Fixed bug where terms like "key" and "nucleus" were not returned in
   webhelp search.

clouddocs-maven-plugin 1.0.8 (01 December 2011)
===============================================

New features and changes
------------------------

-  OpenStack output now has pdf icon and feed icon in header bar.
-  Break the build when the processing instruction ``<?rax fail?>``
   encountered.
-  Support for `shared
   glossary <https://wiki.mosso.com/display/IXD/Glossary>`_.

Bug fixes
---------

-  A number of fixes to the generation of API references from wadl
   files.
-  Added product version number to titles of doc rss feeds.

clouddocs-maven-plugin 1.0.7 (02 November 2011)
===============================================

New features
------------

-  Atom feed from individual documents

   -  If ``<canonicalUrlBase>`` is set, html pages in webhelp now
      include <link rel="canonical"> markup for improved SEO.
   -  `revhistory markup
      documentation <https://wiki.mosso.com/display/IXD/Revision+history+sections+in+DocBook+documents>`_

-  Support for a new comment system for use with internal comments.

   -  To use this system in your pom, set
      ``<enableDisqus>intranet</enableDisqus>`` and ``<feedbackEmail>``
      to the email address to which you would like notifications sent
      when a page is commented on.
   -  As an alternative to ``<feedbackEmail>`` in the pom, you can put
      ``<?rax feedback.email="someemail@rackspace.com"?>`` as a child of
      book in the document.
   -  You can also put a comma-delimited list of emails if you want more
      than one person to be notified.

-  In the wadl normalizer, if you refer to a data type that is an
   enumeration, it converts it to an xs:string with an ``<option>``
   element for each enumerated value.
-  Updated oXygen installer and framework to use oXygen 13.1. See the
   `upgrade
   instructions <https://wiki.rackspace.corp/CloudDocTools/OxygenConfiguration>`_
   for your platform.

Bug fixes
---------

-  Use upper-alpha numbering for appendixes and roman numbering for
   parts in webhelp.
-  Cover title now appears correctly in content build on Windows.
-  Fixed bug where the current section's title always appeared in a
   tooltip when you moused over any text.
-  Added Bold and Italic buttons/menus to Oxygen
-  Fixed bug where content which scroll up a bit each time you clicked
   the Search or Contents tabs.

clouddocs-maven-plugin 1.0.6 (12 October 2011)
==============================================

New Features
------------

-  <glossterm> elements with corresponding <glossentry> elements in a
   glossary are presented as tooltips in webhelp.
-  In webhelp when the toc content is longer than the window and a
   scroll bar appears, the Contents and Search tab area stays fixed
   instead of scrolling away.
-  In webhelp improve formatting of calloutlists (removed table
   borders).
-  wadl2docbook improvements:

   -  Support for pulling in all the methods from a <wadl:resource> if
      the resource in the DocBook document is empty.
   -  Support for pulling in an entire wadl with a single element added
      to the DocBook document.
   -  Other miscellaneous fixes.
   -  See `Generating an API reference from a WADL
      file </display/RED/Generating+an+API+reference+from+a+WADL+file>`_
      for details.

-  New branding value, openstackextension.

Impacts to current projects
---------------------------

-  Projects can have a <glossary> section, which is like a <chapter> or
   <appendix>. This can have glossary entries that give definitions.
   When you use the terms in text, you can use the <glossterm> tag on
   the terms and a popup box will appear when the user rolls over the
   term in webhelp. See `Adding Glossary
   Popups </display/RED/Adding+Glossary+Popups>`_ for details.
-  You can set ``<branding>openstackextension<branding>`` in your POM
   file. When you do, there will be a different page header and cover
   page. Also, Disqus comments will be stored in the OpenStack forum.

clouddocs-maven-plugin 1.0.5 (20 September 2011)
================================================

New Features
------------

-  Initial support for wadl2docbook processing which allows you to
   include wadl or pointers to a wadl in your DocBook file and have the
   wadl processed into human readable output.

   -  To support this, a wadl framework has been added to the Rackspace
      Oxygen customizations. This framework helps you author wadls,
      providing interactive error checking and other assistance.
   -  Also in Oxygen, the Rackbook schema has been modified to allow
      wadl markup in DocBook documents.

-  Support for disqus\_identifier. (This will be used when the document
   is deployed. The writers don't have to do anything.)
-  Ability to separate or include Disqus comments for different versions
   of a document.
-  xml:id required on book, chapter, part, sections
-  Support for formatting ``<parameter role="template">`` as a wadl
   template parameter (i.e. surrounded by curly braces) in Oxygen and
   the output formats.
-  The arrow and check mark images are now available in the common
   images directory.

Bug fixes
---------

-  Fixed bug where ``webhelp.default.topic`` was not being used when set
   in the pom.

Impacts to current projects
---------------------------

-  The xml:id attribute is now required on all book, chapter, section,
   appendix etc. elements. This ensures that in webhelp output we will
   have stable urls.

   -  If you want to build your document and ignore this requirement,
      you must turn off Disqus. Set the enabledisqus variable to 0 like
      this:

      ::

          436503a2577e475a980a335f2943376355facd00
          <enableDisqus>0<enableDisqus>

-  If you want Disqus to use a different thread for different versions
   of your document, use this setting in your POM:

   ::

       <useVersionForDisqus>1<useVersionForDisqus>

-  Support for parameter that controls whether the url or a unique
   disqus id is used to associate comments with content. If you set
   ``<useDisqusId>0</useDisqusId>``, then it omits using the Disqus
   identifier. It turns out that this feature was unnecessary since
   comments that were associated via url are still associated with the
   document after adding the Disqus identifier.

clouddocs-maven-plugin 1.0.4 (09 June 2011)
===========================================

New features and changes
------------------------

-  Experimental support for using Disqus for internal comments if
   ``<enableDisqus>intranet</enableDisqus>`` is set.
-  Add Rackspace branding to Webhelp output
-  Support Disqus comments in Webhelp output
-  Google Analytics tracking in Webhelp output
-  Use admonition graphics in Webhelp output
-  Support callouts up to 30 in Webhelp output
-  Support Draft banner in Webhelp
-  Support use of security param to control conditioning of text.
-  Add section numbers to headings in Webhelp
-  Support for adding a link to the pdf when <pdfUrl> is set in the pom
   or <?rax pdf.url=""?> is set in the document.
-  Stop scaling images in html output
-  Fix for problem where headings appeared below banner when they were
   not at the top of the page (i.e. anchors for non-chunked sections).
-  Add a "Legal notice" link to bottom of the page.
-  All links now point to docs.rackspace.com instead of
   docs.rackspacecloud.com and using target="\_blank" in links.
-  Now depending on Docbkx 2.0.13.
-  Fixed problem with autowrapping in programlistings.
-  No longer output the book toc in webhelp since we already have that
   information in the toc pane.
-  Other miscellaneous fixes.

