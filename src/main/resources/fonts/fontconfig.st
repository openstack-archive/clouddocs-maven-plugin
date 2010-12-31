<?xml version="1.0" encoding="UTF-8"?>


<fop version="1.0">
    <!-- Base URL for resolving relative URLs -->
    <base>.</base>

    <!-- Source resolution in dpi (dots/pixels per inch) for determining the size of pixels in SVG and bitmap images, default: 72dpi -->
    <source-resolution>72</source-resolution>
    <!-- Target resolution in dpi (dots/pixels per inch) for specifying the target resolution for generated bitmaps, default: 72dpi -->
    <target-resolution>72</target-resolution>

    <!-- Default page-height and page-width, in case
         value is specified as auto -->
    <default-page-settings height="11in" width="8.26in"/>

    <renderers>
        <renderer mime="application/pdf">
            <filterList>
                <!-- provides compression using zlib flate (default is on) -->
                <value>flate</value>

                <!-- encodes binary data into printable ascii characters (default off)
                     This provides about a 4:5 expansion of data size -->
                <!-- <value>ascii-85</value> -->

                <!-- encodes binary data with hex representation (default off)
                     This filter is not recommended as it doubles the data size -->
                <!-- <value>ascii-hex</value> -->
            </filterList>
            <fonts>
                <!-- register all the fonts found in a directory and all of its sub directories (use with care) -->
                <font kerning="yes" embed-url="file://$fontPath$/CartoGothic-Std/CartoGothicStd-Book.ttf">
                    <font-triplet name="CartoGothic Std" style="normal" weight="normal"/>
                    <font-triplet name="CartoGothic" style="normal" weight="normal"/>
                </font>
                <font kerning="yes" embed-url="file://$fontPath$/CartoGothic-Std/CartoGothicStd-Bold.ttf">
                    <font-triplet name="CartoGothic Std" style="normal" weight="bold"/>
                    <font-triplet name="CartoGothic" style="normal" weight="bold"/>
                </font>
                <font kerning="yes" embed-url="file://$fontPath$/CartoGothic-Std/CartoGothicStd-Italic.ttf">
                    <font-triplet name="CartoGothic Std" style="italic" weight="normal"/>
                    <font-triplet name="CartoGothic" style="italic" weight="normal"/>
                </font>
                <font kerning="yes" embed-url="file://$fontPath$/CartoGothic-Std/CartoGothicStd-BoldItalic.ttf">
                    <font-triplet name="CartoGothic Std" style="italic" weight="bold"/>
                    <font-triplet name="CartoGothic" style="italic" weight="bold"/>
                </font>
            </fonts>
        </renderer>
    </renderers>
</fop>
