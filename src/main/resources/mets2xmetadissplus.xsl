<!--
  ~ Copyright 2017 Saxon State and University Library Dresden (SLUB)
  ~
  ~ Licensed under the Apache License, Version 2.0 (the "License");
  ~ you may not use this file except in compliance with the License.
  ~ You may obtain a copy of the License at
  ~
  ~     http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing, software
  ~ distributed under the License is distributed on an "AS IS" BASIS,
  ~ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  ~ See the License for the specific language governing permissions and
  ~ limitations under the License.
  -->

<stylesheet xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns="http://www.w3.org/1999/XSL/Transform"
            xmlns:ddb="http://www.d-nb.de/standards/ddb/"
            xmlns:pc="http://www.d-nb.de/standards/pc/"
            xmlns:mets="http://www.loc.gov/METS/"
            xmlns:mods="http://www.loc.gov/mods/v3"
            xmlns:dcterms="http://purl.org/dc/terms/"
            version="2.0"
            xmlns:xMetaDiss="http://www.d-nb.de/standards/xmetadissplus/"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd
                                    http://www.d-nb.de/standards/xmetadissplus/ http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd
                                    http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods.xsd
                                    http://purl.org/dc/elements/1.1/ http://dublincore.org/schemas/xmls/qdc/2008/02/11/dc.xsd
                                    http://www.d-nb.de/standards/pc/ http://files.dnb.de/standards/xmetadiss/pc.xsd
                                    http://www.d-nb.de/standards/ddb/ http://files.dnb.de/standards/xmetadiss/ddb.xsd
                                    http://purl.org/dc/terms/ http://dublincore.org/schemas/xmls/qdc/2008/02/11/dcterms.xsd">

    <output standalone="yes" encoding="utf-8" media-type="application/xml" indent="yes" method="xml"/>

    <strip-space elements="*"/>

    <template match="/mets:mets">
        <xMetaDiss:xMetaDiss>
            <apply-templates select="mets:dmdSec[@ID='DMD_000']/mets:mdWrap[@MDTYPE='MODS']/mets:xmlData/mods:mods"/>
        </xMetaDiss:xMetaDiss>
    </template>

    <template match="mods:mods">
        <!-- dc:title -->
        <apply-templates select="mods:titleInfo[@usage='primary']"/>
        <!-- dc:creator -->
        <apply-templates select="mods:name[@type='personal' and mods:role/mods:roleTerm='aut']"/>
        <!-- dc:subject -->
        <apply-templates select="mods:classification"/>
    </template>

    <template match="mods:titleInfo">
        <dc:title xsi:type="ddb:titleISO639-2" xml:lang="{@lang}">
            <value-of select="mods:title"/>
        </dc:title>
    </template>

    <template match="mods:name[@type='personal']">
        <dc:creator xsi:type="pc:MetaPers">
            <pc:person>
                <pc:name type="nameUsedByThePerson">
                    <pc:foreName>
                        <value-of select="mods:namePart[@type='given']"/>
                    </pc:foreName>
                    <pc:surName>
                        <value-of select="mods:namePart[@type='family']"/>
                    </pc:surName>
                </pc:name>
            </pc:person>
        </dc:creator>
    </template>

    <template match="mods:classification[@authority='z']">
        <dc:subject xsi:type="xMetaDiss:noScheme">
            <value-of select="text()"/>
        </dc:subject>
    </template>

    <template match="mods:classification[@authority='ddc']">
        <dc:subject xsi:type="dcterms:DDC">
            <value-of select="text()"/>
        </dc:subject>
        <dc:subject xsi:type="xMetaDiss:DDC-SG">
            <value-of select="text()"/>
        </dc:subject>
    </template>

    <template match="text()"/>

</stylesheet>
