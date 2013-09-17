<?xml version="1.0" encoding="utf-8"?>
<p:declare-step version='1.0' name="main"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:l="http://xproc.org/library"
    xmlns:ex="http://xproc.org/ns/xproc/ex">

    <p:input port="source"/>
    
    <p:output port="result"/>
    
    <p:import href="http://xproc.org/library/relax-ng-report.xpl"/>
    
    <p:declare-step type="cx:report-errors">
        <p:input port="source" primary="true"/>
        <p:input port="report" sequence="true"/>
        <p:output port="result"/>
        <p:option name="code"/>
        <p:option name="code-prefix"/>
        <p:option name="code-namespace"/>
    </p:declare-step>
    
    <l:relax-ng-report name="validate">
        <p:input port="schema">
            <p:document href="http://docs-beta.rackspace.com/oxygen/13.1/mac/author/frameworks/rackbook/5.0/rng/rackbook.rng"/>
        </p:input>
    </l:relax-ng-report>
    
    <cx:report-errors name="report-errors" >
        <p:input port="source">
            <p:pipe step="validate" port="result"/>
        </p:input>
        <p:input port="report">
            <p:pipe step="validate" port="report"/>
        </p:input>
    </cx:report-errors>
    
</p:declare-step>