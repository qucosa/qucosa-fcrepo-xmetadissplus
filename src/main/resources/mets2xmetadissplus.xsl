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
            xmlns:subject="http://www.d.nb.de/standards/subject/"
            xmlns:cc="http://www.d-nb.de/standards/cc/"
            xmlns:thesis="http://www.ndltd.org/standards/metadata/etdms/1.0/"
            xmlns:myfunc="urn:de:qucosa:xmetadissplus"
            xmlns:dini="http://www.d-nb.de/standards/xmetadissplus/type/"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:urn="http://www.d-nb.de/standards/urn/"
            version="2.0"
            xmlns:xMetaDiss="http://www.d-nb.de/standards/xmetadissplus/"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd
                                    http://www.d-nb.de/standards/xmetadissplus/ http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd
                                    http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods.xsd
                                    http://purl.org/dc/elements/1.1/ http://dublincore.org/schemas/xmls/qdc/2008/02/11/dc.xsd
                                    http://www.d-nb.de/standards/pc/ http://files.dnb.de/standards/xmetadiss/pc.xsd
                                    http://www.d-nb.de/standards/ddb/ http://files.dnb.de/standards/xmetadiss/ddb.xsd
                                    http://purl.org/dc/terms/ http://dublincore.org/schemas/xmls/qdc/2008/02/11/dcterms.xsd
                                    http://www.d.nb.de/standards/subject/ http://files.dnb.de/standards/xmetadiss/subject.xsd
                                    http://www.d-nb.de/standards/cc/ http://files.dnb.de/standards/xmetadiss/cc.xsd
                                    http://www.ndltd.org/standards/metadata/etdms/1.0/ http://files.dnb.de/standards/xmetadiss/thesis.xsd
                                    http://www.w3.org/2001/XMLSchema https://www.w3.org/2009/XMLSchema/XMLSchema.xsd
                                    http://www.d-nb.de/standards/xmetadissplus/type/ http://files.dnb.de/standards/xmetadissplus/xmetadissplustype.xsd
                                    http://www.d-nb.de/standards/urn/ http://files.dnb.de/standards/xmetadiss/urn.xsd">

    <output standalone="yes" encoding="utf-8" media-type="application/xml" indent="yes" method="xml"/>

    <strip-space elements="*"/>

    <!-- Main control templates -->

    <template match="/mets:mets">
        <xMetaDiss:xMetaDiss>
            <apply-templates select="mets:dmdSec[@ID='DMD_000']/mets:mdWrap[@MDTYPE='MODS']/mets:xmlData/mods:mods"/>
        </xMetaDiss:xMetaDiss>
    </template>

    <template match="mods:mods">
        <!-- dc:title -->
        <apply-templates select="mods:titleInfo[@usage='primary']"/>
        <!-- dc:creator -->
        <apply-templates select="mods:name[@type='personal' and mods:role/mods:roleTerm='aut']" mode="dc:creator"/>
        <!-- dc:subject -->
        <apply-templates select="mods:classification"/>
        <!-- dcterms:tableOfContents -->
        <apply-templates select="mods:tableOfContents"/>
        <!-- dcterms:abstract -->
        <apply-templates select="mods:abstract[@type='summary']"/>
        <!-- dc:publisher -->
        <apply-templates select="mods:name[@type='corporate' and mods:role/mods:roleTerm='pbl']" mode="dc:publisher"/>
        <!-- dc:contributor -->
        <apply-templates select="mods:name[@type='personal' and (
                                    mods:role/mods:roleTerm='edt' or
                                    mods:role/mods:roleTerm='rev' or
                                    mods:role/mods:roleTerm='sad' or
                                    mods:role/mods:roleTerm='ths')]" mode="dc:contributor"/>
        <!-- dcterms:dateSubmitted -->
        <apply-templates select="mods:originInfo[@eventType='publication']/mods:dateOther[@type='submission']"/>
        <!-- dcterms:issued -->
        <apply-templates select="mods:originInfo[@eventType='publication']/mods:dateIssued"/>
        <!-- dcterms:modified -->
        <apply-templates select="/mets:mets/mets:metsHdr/@LASTMODDATE"/>
        <!-- dc:type -->
        <apply-templates select="/mets:mets/mets:structMap[@TYPE='LOGICAL']/mets:div/@TYPE"/>
        <!-- dini:version_driver -->
        <apply-templates select="mods:originInfo[@eventType='production']/mods:edition" mode="dini:version_driver"/>
        <!-- dc:identifier -->
        <apply-templates select="mods:identifier[@type='qucosa:urn']"/>

        <!-- SKIP dcterms:extend -->
        <!-- SKIP dcterms:medium -->
        <!-- SKIP dcterms:bibliographicCitation -->

        <!-- dc:source -->
        <apply-templates select="mods:relatedItem[@type='otherFormat']"/>

        <!-- dc:language -->
        <apply-templates select="mods:language/mods:languageTerm[@authority='iso639-2b' and @type='code']"/>

        <!-- SKIP dc:relation -->
        <!-- SKIP dc:coverage -->
        <!-- SKIP dc:rights -->
    </template>

    <!-- individual METS/MODS element templates -->

    <template match="mods:titleInfo">
        <dc:title xsi:type="ddb:titleISO639-2" xml:lang="{@lang}">
            <value-of select="mods:title"/>
        </dc:title>
    </template>

    <template match="mods:name[@type='personal']" mode="dc:creator">
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

    <template match="mods:name[@type='personal']" mode="dc:contributor">
        <dc:contributor xsi:type="pc:Contributor"
                        thesis:role="{myfunc:thesisRole(mods:role/mods:roleTerm[@type='code'])}">
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
        </dc:contributor>
    </template>

    <template match="mods:name[@type='corporate']" mode="dc:publisher">
        <dc:publisher xsi:type="cc:Publisher">
            <cc:universityOrInstitution>
                <cc:name>
                    <value-of select="mods:namePart"/>
                </cc:name>
            </cc:universityOrInstitution>
        </dc:publisher>
    </template>

    <template match="mods:classification[@authority='z']">
        <dc:subject xsi:type="subject:noScheme">
            <value-of select="text()"/>
        </dc:subject>
    </template>

    <template match="mods:classification[@authority='ddc']">
        <dc:subject xsi:type="dcterms:DDC">
            <value-of select="text()"/>
        </dc:subject>
        <dc:subject xsi:type="subject:DDC-SG">
            <value-of select="text()"/>
        </dc:subject>
    </template>

    <template match="mods:tableOfContents">
        <dcterms:tableOfContents xsi:type="ddb:contentISO639-2" ddb:type="subject:noScheme">
            <call-template name="elementLanguageAttributeWithFallback"/>
            <value-of select="."/>
        </dcterms:tableOfContents>
    </template>

    <template match="mods:abstract">
        <dcterms:abstract xsi:type="ddb:contentISO639-2" ddb:type="subject:noScheme">
            <call-template name="elementLanguageAttributeWithFallback"/>
            <value-of select="."/>
        </dcterms:abstract>
    </template>

    <template match="mods:dateOther[@type='submission']">
        <dcterms:dateSubmitted xsi:type="dcterms:W3CDTF">
            <value-of select="myfunc:formatDateTime(.)"/>
        </dcterms:dateSubmitted>
    </template>

    <template match="mods:dateIssued">
        <dcterms:issued xsi:type="dcterms:W3CDTF">
            <value-of select="myfunc:formatDateTime(.)"/>
        </dcterms:issued>
    </template>

    <template match="mets:metsHdr/@LASTMODDATE">
        <dcterms:modified xsi:type="dcterms:W3CDTF">
            <value-of select="myfunc:formatDateTime(.)"/>
        </dcterms:modified>
    </template>

    <template match="mets:structMap[@TYPE='LOGICAL']/mets:div/@TYPE">
        <dc:type xsi:type="dini:PublType">
            <value-of select="myfunc:diniDocumentType(.)"/>
        </dc:type>
    </template>

    <template match="mods:edition" mode="dini:version_driver">
        <dini:version_driver>
            <choose>
                <when test=".='draft'">draft</when>
                <when test=".='submitted'">submittedVersion</when>
                <when test=".='accepted'">acceptedVersion</when>
                <when test=".='published'">publishedVersion</when>
                <when test=".='updated'">updatedVersion</when>
                <otherwise>
                    <message terminate="yes" xml:space="preserve">ERROR: Document state cannot be mapped to DINI vocabulary.</message>
                </otherwise>
            </choose>
        </dini:version_driver>
    </template>

    <template match="mods:identifier[@type='qucosa:urn']">
        <dc:identifier xsi:type="urn:nbn">
            <value-of select="."/>
        </dc:identifier>
    </template>

    <template match="mods:relatedItem[@type='otherFormat']/mods:location/mods:url">
        <dc:source xsi:type="dcterms:URI">
            <value-of select="."/>
        </dc:source>
    </template>

    <template match="mods:relatedItem[@type='otherFormat']/mods:identifier[@type='isbn']">
        <dc:source xsi:type="ddb:ISBN">
            <value-of select="."/>
        </dc:source>
    </template>

    <template match="mods:language/mods:languageTerm[@authority='iso639-2b' and @type='code']">
        <dc:language xsi:type="dcterms:ISO639-2">
            <value-of select="."/>
        </dc:language>
    </template>

    <!-- eat all unmatched text content -->

    <template match="text()"/>

    <!-- Helper functions and templates -->

    <function name="myfunc:formatDateTime" as="xs:string">
        <param name="value" as="xs:string"/>
        <choose>
            <when test="contains($value, 'T')">
                <value-of select="format-dateTime(xs:dateTime($value), '[Y0001]-[M01]-[D01]')"/>
            </when>
            <otherwise>
                <value-of select="format-date(xs:date($value), '[Y0001]-[M01]-[D01]')"/>
            </otherwise>
        </choose>
    </function>

    <template name="elementLanguageAttributeWithFallback">
        <attribute name="xml:lang">
            <choose>
                <!-- If element has @lang attribute use its value -->
                <when test="string(@lang)">
                    <value-of select="@lang"/>
                </when>
                <!-- If the element has no @lang attribute fallback to mods:languageTerm element -->
                <when test="../mods:language/mods:languageTerm[@authority='iso639-2b']">
                    <value-of select="../mods:language/mods:languageTerm[@authority='iso639-2b']"/>
                </when>
                <!-- If there is no language code obtainable, end transformation with error -->
                <otherwise>
                    <message terminate="yes" xml:space="preserve">ERROR: No @lang attribute in selected element and no mods:language/mods:languageTerm element found.</message>
                </otherwise>
            </choose>
        </attribute>
    </template>

    <function name="myfunc:thesisRole" as="xs:string">
        <param name="role"/>
        <choose>
            <when test="$role = 'edt'">editor</when>
            <when test="$role = 'rev'">referee</when>
            <when test="$role = 'sad'">advisor</when>
            <when test="$role = 'ths'">advisor</when>
            <otherwise>
                <message terminate="yes" xml:space="preserve">ERROR: Referenced contributor role is not defined for xMetaDissPlus.</message>
            </otherwise>
        </choose>
    </function>

    <function name="myfunc:diniDocumentType" as="xs:string">
        <param name="type"/>
        <choose>
            <when test="$type = 'article'">article</when>
            <when test="$type = 'bachelor_thesis'">bachelorThesis</when>
            <when test="$type = 'contained_work'">bookPart</when>
            <when test="$type = 'diploma_thesis'">masterThesis</when>
            <when test="$type = 'doctoral_thesis'">doctoralThesis</when>
            <when test="$type = 'habilitation_thesis'">doctoralThesis</when>
            <when test="$type = 'in_proceeding'">conferenceObject</when>
            <when test="$type = 'issue'">PeriodicalPart</when>
            <when test="$type = 'lecture'">lecture</when>
            <when test="$type = 'magister_thesis'">masterThesis</when>
            <when test="$type = 'monograph'">book</when>
            <when test="$type = 'musical_notation'">MusicalNotation</when>
            <when test="$type = 'paper'">StudyThesis</when>
            <when test="$type = 'periodical'">Periodical</when>
            <when test="$type = 'preprint'">preprint</when>
            <when test="$type = 'proceeding'">conferenceObject</when>
            <when test="$type = 'report'">report</when>
            <when test="$type = 'research_paper'">workingPaper</when>
            <when test="$type = 'series'">Periodical</when>
            <!--
                Types `multivolume_work` and `text` are not defined for DINI and are mapped to `Other`
             -->
            <otherwise>Other</otherwise>
        </choose>
    </function>

</stylesheet>
