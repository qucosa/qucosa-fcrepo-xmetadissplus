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
            xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
            xmlns:ddb="http://www.d-nb.de/standards/ddb/"
            xmlns:pc="http://www.d-nb.de/standards/pc/"
            xmlns:mets="http://www.loc.gov/METS/"
            xmlns:mods="http://www.loc.gov/mods/v3"
            xmlns:dcterms="http://purl.org/dc/terms/"
            xmlns:cc="http://www.d-nb.de/standards/cc/"
            xmlns:thesis="http://www.ndltd.org/standards/metadata/etdms/1.0/"
            xmlns:myfunc="urn:de:qucosa:xmetadissplus"
            xmlns:dini="http://www.d-nb.de/standards/xmetadissplus/type/"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:urn="http://www.d-nb.de/standards/urn/"
            xmlns:slub="http://slub-dresden.de/"
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
                                    http://www.d-nb.de/standards/cc/ http://files.dnb.de/standards/xmetadiss/cc.xsd
                                    http://www.ndltd.org/standards/metadata/etdms/1.0/ http://files.dnb.de/standards/xmetadiss/thesis.xsd
                                    http://www.w3.org/2001/XMLSchema https://www.w3.org/2009/XMLSchema/XMLSchema.xsd
                                    http://www.d-nb.de/standards/xmetadissplus/type/ http://files.dnb.de/standards/xmetadissplus/xmetadissplustype.xsd
                                    http://www.d-nb.de/standards/urn/ http://files.dnb.de/standards/xmetadiss/urn.xsd">

    <output encoding="utf-8" media-type="application/xml" indent="yes" method="xml"/>

    <strip-space elements="*"/>

    <!-- Transfer URL parameter, passed from dissemination servlet -->
    <param name="transfer_url"/>

    <!-- Variable containing the document type -->
    <variable name="document_type" select="//mets:mets/mets:structMap[@TYPE='LOGICAL']/mets:div/@TYPE"/>

    <!-- Main control templates -->

    <template match="/mets:mets">
        <xMetaDiss:xMetaDiss xsi:schemaLocation="http://www.d-nb.de/standards/xmetadissplus/ http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd">
            <apply-templates select="mets:dmdSec[@ID='DMD_000']/mets:mdWrap[@MDTYPE='MODS']/mets:xmlData/mods:mods"/>

            <!-- ddb:rights -->
            <call-template name="ddb:rights"/>

        </xMetaDiss:xMetaDiss>
    </template>

    <template match="mods:mods">
        <!-- dc:title -->
        <apply-templates select="mods:titleInfo[@usage='primary']"/>
        <!-- dcterms:alternative -->
        <apply-templates select="mods:titleInfo[not(@usage='primary')]/mods:title" mode="alternative"/>
        <apply-templates select="mods:titleInfo[not(@usage='primary')]/mods:subTitle"/>
        <!-- dc:creator -->
        <apply-templates select="mods:name[@type='personal' and mods:role/mods:roleTerm='aut']" mode="dc:creator"/>
        <apply-templates select="mods:name[@type='personal' and mods:role/mods:roleTerm='cmp']" mode="dc:creator"/>
        <apply-templates select="mods:name[@type='personal' and mods:role/mods:roleTerm='art']" mode="dc:creator"/>
        <!-- dc:subject -->
        <apply-templates select="mods:classification"/>
        <!-- dcterms:tableOfContents -->
        <apply-templates select="mods:tableOfContents"/>
        <!-- dcterms:abstract -->
        <apply-templates select="mods:abstract[@type='summary']"/>
        <!-- dc:publisher -->
        <apply-templates select="mods:name[@type='corporate' and myfunc:nodesMatch(mods:role/mods:roleTerm, 'pbl|edt|prv')]"/>
        <!-- dc:contributor -->
        <apply-templates select="mods:name[@type='personal' and (
                                    mods:role/mods:roleTerm='dgs' or
                                    mods:role/mods:roleTerm='edt' or
                                    mods:role/mods:roleTerm='red' or
                                    mods:role/mods:roleTerm='rev' or
                                    mods:role/mods:roleTerm='sad' or
                                    mods:role/mods:roleTerm='ths')]" mode="dc:contributor"/>
        <!-- dcterms:created -->
        <apply-templates select="mods:originInfo[@eventType='publication']/mods:dateIssued" mode="dcterms:created"/>
        <!-- dcterms:dateSubmitted -->
        <apply-templates select="mods:originInfo[@eventType='publication']/mods:dateOther[@type='submission']"/>
        <!-- dcterms:dateAccepted -->
        <apply-templates select="mods:originInfo[@eventType='publication']/mods:dateOther[@type='defense']"/>
        <!-- dcterms:issued -->
        <apply-templates select="mods:originInfo[@eventType='distribution']/mods:dateIssued" mode="dcterms:issued"/>

        <!-- dcterms:modified -->
        <apply-templates select="/mets:mets/mets:metsHdr/@LASTMODDATE"/>
        <!-- dc:type -->
        <apply-templates select="/mets:mets/mets:structMap[@TYPE='LOGICAL']/mets:div/@TYPE"/>
        <!-- dini:version_driver -->
        <apply-templates select="mods:originInfo[@eventType='production']/mods:edition" mode="dini:version_driver"/>
        <!-- dc:identifier -->
        <apply-templates select="mods:identifier[@type='qucosa:urn']" mode="dc:identifier"/>

        <!-- SKIP dcterms:extent -->

        <!-- dcterms:medium -->
        <!--
            HACK for bug in WinIBW xMetaDissPlus2Pica script.
         -->
        <dcterms:medium/>

        <!-- SKIP dcterms:bibliographicCitation -->

        <!-- dc:source -->
        <apply-templates select="mods:identifier[@type='isbn']" mode="dc:source"/>
        <apply-templates select="mods:relatedItem[@type='otherFormat']"/>
        <apply-templates select="mods:relatedItem[@type='original' and mods:titleInfo/mods:title]" mode="dc:source"/>
        <apply-templates select="mods:relatedItem[@type='host']/mods:note[@type='z']"/>

        <!-- dc:language -->
        <apply-templates select="mods:language/mods:languageTerm[@authority='iso639-2b' and @type='code']"/>

        <!-- dc:relation -->
        <apply-templates select="//slub:info" mode="dc:relation"/>
        <!-- SKIP dc:isVersionOf -->
        <!-- SKIP dc:hasVersion -->

        <!-- dcterms:isReplacedBy -->
        <apply-templates select="mods:relatedItem[@type='succeeding']/mods:location/mods:url"/>
        <apply-templates select="mods:relatedItem[@type='succeeding']/mods:identifier"/>
        <apply-templates select="mods:relatedItem[@type='succeeding']/mods:note"/>

        <!-- dcterms:replaces -->
        <apply-templates select="mods:relatedItem[@type='preceding']/mods:location/mods:url"/>
        <apply-templates select="mods:relatedItem[@type='preceding']/mods:identifier"/>
        <apply-templates select="mods:relatedItem[@type='preceding']/mods:note"/>

        <!-- SKIP dc:isRequiredBy -->
        <!-- SKIP dc:requires -->

        <!-- dcterms:isPartOf -->
        <apply-templates select="mods:part[@type='issue']/mods:detail/mods:number" mode="ZS-Ausgabe"/>
        <apply-templates select="mods:relatedItem[@type='host']" mode="ZS-Ausgabe"/>
        <apply-templates select="mods:relatedItem[@type='host']/mods:identifier[contains(@type, 'urn') or @type='issn']" mode="ZS-TitelID"/>
        <apply-templates select="mods:relatedItem[@type='host']//mods:identifier[@type='zdb']" mode="dcterms:isPartOf"/>
        <apply-templates select="mods:relatedItem[@type='host']/mods:relatedItem[@type='host']/mods:identifier[contains(@type, 'urn')]" mode="dcterms:isPartOf"/>
        <apply-templates select="mods:relatedItem[@type='series']/mods:titleInfo[1]/mods:title[1]" mode="dcterms:isPartOf"/>
        <apply-templates select="mods:relatedItem[@type='series']/mods:identifier[@type='issn']" mode="dcterms:isPartOf"/>
        <apply-templates select="mods:relatedItem[@type='series']/mods:identifier[@type='urn']" mode="dcterms:isPartOf"/>

        <!-- SKIP dc:coverage -->

        <!-- dc:rights -->
        <apply-templates select="/mets:mets/mets:amdSec//slub:info" mode="dc:rights"/>

        <!-- thesis:degree -->
        <call-template name="thesisDegreeElement">
            <with-param name="type" select="/mets:mets/mets:structMap[@TYPE='LOGICAL']/mets:div/@TYPE"/>
        </call-template>

        <!-- Skip ddb:contact -->

        <!-- ddb:fileNumber -->
        <ddb:fileNumber>
            <value-of select="count(//mets:fileSec/mets:fileGrp[@USE='DOWNLOAD']/mets:file[@USE='ARCHIVE'])"/>
        </ddb:fileNumber>

        <!-- Skip: ddb:fileProperties -->
        <!-- Skip: ddb:checksum -->

        <!-- ddb:transfer -->
        <ddb:transfer ddb:type="dcterms:URI">
            <value-of select="$transfer_url"/>
        </ddb:transfer>

        <!-- ddb:identifier -->
        <apply-templates select="mods:identifier" mode="ddb:identifier"/>
        <apply-templates select="/mets:mets/mets:amdSec//slub:info/slub:vgwortOpenKey" mode="ddb:identifier"/>

    </template>

    <!-- individual METS/MODS element templates -->

    <template match="mods:titleInfo/mods:title">
        <dc:title xsi:type="ddb:titleISO639-2">
            <if test="../@lang">
                <attribute name="lang" select="../@lang"/>
            </if>
            <value-of select="."/>
        </dc:title>
    </template>

    <template match="mods:titleInfo/mods:title" mode="alternative">
        <variable name="titleLanguage" select="../@lang"/>
        <variable name="documentLanguage"
                  select="/mets:mets//mods:mods/mods:language/mods:languageTerm[@type='code'][1]"/>
        <dcterms:alternative xsi:type="ddb:titleISO639-2" lang="{$titleLanguage}">
            <if test="$titleLanguage != $documentLanguage">
                <attribute name="ddb:type">translated</attribute>
            </if>
            <value-of select="."/>
        </dcterms:alternative>
    </template>

    <template match="mods:titleInfo/mods:subTitle">
        <variable name="titleLanguage" select="../@lang"/>
        <variable name="documentLanguage"
                  select="/mets:mets//mods:mods/mods:language/mods:languageTerm[@type='code'][1]"/>
        <dcterms:alternative xsi:type="ddb:talternativeISO639-2" lang="{$titleLanguage}">
            <if test="$titleLanguage != $documentLanguage">
                <attribute name="ddb:type">translated</attribute>
            </if>
            <value-of select="."/>
        </dcterms:alternative>
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
                <xslt:if test="mods:namePart[@type='termsOfAddress']">
                    <pc:academicTitle>
                        <value-of select="mods:namePart[@type='termsOfAddress']"/>
                    </pc:academicTitle>
                </xslt:if>
            </pc:person>
        </dc:creator>
    </template>

    <template match="mods:name[@type='personal']" mode="dc:contributor">
        <for-each select="mods:role/mods:roleTerm[@type='code']">
            <if test="myfunc:thesisRole(.) != 'error'">
                <dc:contributor xsi:type="pc:Contributor"
                                thesis:role="{myfunc:thesisRole(.)}">
                    <pc:person>
                        <pc:name type="nameUsedByThePerson">
                            <pc:foreName>
                                <value-of select="../../mods:namePart[@type='given']"/>
                            </pc:foreName>
                            <pc:surName>
                                <value-of select="../../mods:namePart[@type='family']"/>
                            </pc:surName>
                        </pc:name>
                        <xslt:if test="../../mods:namePart[@type='termsOfAddress']">
                            <pc:academicTitle>
                                <value-of select="../../mods:namePart[@type='termsOfAddress']"/>
                            </pc:academicTitle>
                        </xslt:if>
                    </pc:person>
                </dc:contributor>
            </if>
        </for-each>
    </template>

    <template match="mods:name[@type='corporate' and myfunc:nodesMatch(mods:role/mods:roleTerm, 'pbl|edt|prv')]">
        <variable name="corporation_node" select="myfunc:referencingSlubCorporationElement(., @ID)"/>
        <dc:publisher xsi:type="cc:Publisher" ddb:role="{mods:role/mods:roleTerm}">
            <cc:universityOrInstitution>
                <if test="mods:nameIdentifier[@type='gnd']">
                    <attribute name="cc:GKD-Nr" select="mods:nameIdentifier[@type='gnd']"/>
                </if>
                <cc:name>
                    <value-of select="mods:namePart[1]"/>
                </cc:name>
                <if test="$corporation_node/@place">
                    <cc:place>
                        <value-of select="$corporation_node/@place"/>
                    </cc:place>
                </if>
            </cc:universityOrInstitution>
            <cc:address>
                <choose>
                    <when test="$corporation_node/@address">
                        <value-of select="$corporation_node/@address"/>
                    </when>
                    <when test="$corporation_node/@place">
                        <value-of select="$corporation_node/@place"/>
                    </when>
                </choose>
            </cc:address>
        </dc:publisher>
    </template>

    <template match="mods:classification[@authority='z']">
        <for-each select="tokenize(text(), ', ')">
            <dc:subject xsi:type="xMetaDiss:noScheme">
                <value-of select="."/>
            </dc:subject>
        </for-each>
    </template>

    <template match="mods:classification[@authority='ddc']">
        <for-each select="tokenize(text(), ', ')">
            <dc:subject xsi:type="dcterms:DDC">
                <value-of select="."/>
            </dc:subject>
            <dc:subject xsi:type="xMetaDiss:DDC-SG">
                <value-of select="."/>
            </dc:subject>
        </for-each>
    </template>

    <template match="mods:classification[@authority='rvk']">
        <for-each select="tokenize(text(), ', ')">
            <dc:subject xsi:type="xMetaDiss:RVK">
                <value-of select="."/>
            </dc:subject>
        </for-each>
    </template>

    <template match="mods:classification[@authority='sswd']">
        <for-each select="tokenize(text(), ', ')">
            <dc:subject xsi:type="xMetaDiss:SWD">
                <value-of select="."/>
            </dc:subject>
        </for-each>
    </template>

    <template match="mods:tableOfContents">
        <dcterms:tableOfContents xsi:type="ddb:contentISO639-2" ddb:type="noScheme">
            <call-template name="elementLanguageAttributeWithFallback"/>
            <value-of select="."/>
        </dcterms:tableOfContents>
    </template>

    <template match="mods:abstract">
        <dcterms:abstract xsi:type="ddb:contentISO639-2" ddb:type="noScheme">
            <call-template name="elementLanguageAttributeWithFallback"/>
            <value-of select="."/>
        </dcterms:abstract>
    </template>

    <template match="mods:dateOther[@type='submission']">
        <choose>
            <when test="string-length(normalize-space(.)) = 0">
                <comment>dcterms:dateSubmitted could not be created, missing value in
                    mods:dateOther[@type='submission']
                </comment>
            </when>
            <otherwise>
                <dcterms:dateSubmitted xsi:type="dcterms:W3CDTF">
                    <value-of select="myfunc:formatDateTime(.)"/>
                </dcterms:dateSubmitted>
            </otherwise>
        </choose>
    </template>

    <template match="mods:dateOther[@type='defense']">
        <choose>
            <when test="string-length(normalize-space(.)) = 0">
                <comment>dcterms:dateAccepted could not be created, missing value in mods:dateOther[@type='defense']
                </comment>
            </when>
            <otherwise>
                <dcterms:dateAccepted xsi:type="dcterms:W3CDTF">
                    <value-of select="myfunc:formatDateTime(.)"/>
                </dcterms:dateAccepted>
            </otherwise>
        </choose>
    </template>

    <template match="mods:dateIssued" mode="dcterms:issued">
        <choose>
            <when test="string-length(normalize-space(.)) = 0">
                <comment>dcterms:issued could not be created, missing value in mods:dateIssued</comment>
            </when>
            <otherwise>
                <dcterms:issued xsi:type="dcterms:W3CDTF">
                    <value-of select="myfunc:formatDateTime(.)"/>
                </dcterms:issued>
            </otherwise>
        </choose>
    </template>

    <template match="mods:dateIssued" mode="dcterms:created">
        <choose>
            <when test="string-length(normalize-space(.)) = 0">
                <comment>dcterms:created could not be created, missing value in mods:dateIssued</comment>
            </when>
            <otherwise>
                <dcterms:created xsi:type="dcterms:W3CDTF">
                    <value-of select="myfunc:formatDateTime(.)"/>
                </dcterms:created>
            </otherwise>
        </choose>
    </template>

    <template match="mets:metsHdr/@LASTMODDATE">
        <choose>
            <when test="string-length(normalize-space(.)) = 0">
                <comment>dcterms:modified could not be created, missing value in mets:metsHdr[@LASTMODDATE]</comment>
            </when>
            <otherwise>
                <dcterms:modified xsi:type="dcterms:W3CDTF">
                    <value-of select="myfunc:formatDateTime(.)"/>
                </dcterms:modified>
            </otherwise>
        </choose>
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

    <template match="mods:relatedItem[@type='preceding']/mods:location/mods:url">
        <dcterms:replaces xsi:type="dcterms:URI">
            <value-of select="."/>
        </dcterms:replaces>
    </template>

    <template match="mods:relatedItem[@type='preceding']/mods:identifier[@type='isbn']">
        <dcterms:replaces xsi:type="ddb:ISBN">
            <value-of select="."/>
        </dcterms:replaces>
    </template>

    <template match="mods:relatedItem[@type='preceding']/mods:identifier[contains('urn', @type)]">
        <dcterms:replaces xsi:type="dcterms:URI">
            <value-of select="concat('https//nbn-resolving.de/',text())"/>
        </dcterms:replaces>
    </template>

    <template match="mods:relatedItem[@type='preceding']/mods:note">
        <dcterms:replaces xsi:type="ddb:noScheme">
            <value-of select="."/>
        </dcterms:replaces>
    </template>

    <template match="mods:relatedItem[@type='succeeding']/mods:location/mods:url">
        <dcterms:isReplacedBy xsi:type="dcterms:URI">
            <value-of select="."/>
        </dcterms:isReplacedBy>
    </template>

    <template match="mods:relatedItem[@type='succeeding']/mods:identifier[@type='isbn']">
        <dcterms:isReplacedBy xsi:type="ddb:ISBN">
            <value-of select="."/>
        </dcterms:isReplacedBy>
    </template>

    <template match="mods:relatedItem[@type='succeeding']/mods:identifier[contains('urn', @type)]">
        <dcterms:isReplacedBy xsi:type="dcterms:URI">
            <value-of select="concat('https//nbn-resolving.de/',text())"/>
        </dcterms:isReplacedBy>
    </template>

    <template match="mods:relatedItem[@type='succeeding']/mods:note">
        <dcterms:isReplacedBy xsi:type="ddb:noScheme">
            <value-of select="."/>
        </dcterms:isReplacedBy>
    </template>

    <template match="mods:relatedItem[@type='original' and mods:titleInfo/mods:title]" mode="dc:source">
        <variable name="isbn" select="mods:identifier[@type='isbn'][1]"/>

        <dc:source xsi:type="ddb:noScheme">
            <call-template name="sourceCitation">
                <with-param name="documentType" select="$document_type"/>
                <with-param name="isbn" select="$isbn"/>
                <with-param name="issn" select="mods:identifier[@type='issn'][1]"/>
                <with-param name="issue" select="mods:part[@type='issue']/mods:detail/mods:number"/>
                <with-param name="pagesEnd" select="../mods:part[@type='section']/mods:extent[@unit='pages']/mods:end"/>
                <with-param name="pagesStart" select="../mods:part[@type='section']/mods:extent[@unit='pages']/mods:start"/>
                <with-param name="publisher" select="mods:originInfo/mods:publisher"/>
                <with-param name="publisherPlace" select="mods:originInfo/mods:place/mods:placeTerm"/>
                <with-param name="subTitle" select="mods:titleInfo/mods:subTitle[1]"/>
                <with-param name="title" select="mods:titleInfo/mods:title[1]"/>
                <with-param name="volume" select="mods:part[@type='volume']/mods:detail/mods:number"/>
                <with-param name="year" select="mods:originInfo/mods:dateIssued"/>
            </call-template>
        </dc:source>

        <if test="string-length($isbn)>0">
            <dc:source xsi:type="ddb:ISBN">
                <value-of select="$isbn"/>
            </dc:source>
        </if>

        <variable name="urn" select="mods:identifier[@type='urn'][1]"/>
        <if test="string-length($urn)>0">
            <dc:source xsi:type="dcterms:URI">
                <value-of select="concat('http://nbn-resolving.de/', $urn)"/>
            </dc:source>
        </if>
    </template>

    <template match="mods:relatedItem[@type='host']" mode="ZS-Ausgabe">
        <choose>
            <when test="mods:note[@type='z']">
                <dcterms:isPartOf xsi:type="ddb:ZS-Ausgabe">
                    <value-of select="mods:note[@type='z']"/>
                </dcterms:isPartOf>
            </when>
            <when test="mods:part[@type='issue'] and mods:originInfo/mods:dateIssued">
                <dcterms:isPartOf xsi:type="ddb:ZS-Ausgabe">
                    <variable name="volume" select="mods:part[@type='volume']"/>
                    <variable name="year" select="mods:originInfo/mods:dateIssued"/>
                    <variable name="issue" select="mods:part[@type='issue']"/>
                    <value-of select="string-join(($volume, $year, $issue)[.!=''], ',')"/>
                </dcterms:isPartOf>
            </when>
        </choose>
    </template>

    <template match="mods:part[@type='issue']/mods:detail/mods:number" mode="ZS-Ausgabe">
        <dcterms:isPartOf xsi:type="ddb:ZS-Ausgabe">
            <value-of select="."/>
        </dcterms:isPartOf>
    </template>

    <template match="mods:relatedItem[@type='host']/mods:note[@type='z']">
        <dc:source xsi:type="ddb:noScheme">
            <value-of select="."/>
        </dc:source>
    </template>

    <template match="mods:relatedItem[@type='series']/mods:titleInfo[1]/mods:title[1]" mode="dcterms:isPartOf">
        <dcterms:isPartOf xsi:type="ddb:noScheme">
            <value-of select="."/>
            <variable name="volume" select="../../../mods:part[@type='volume'][1]/mods:detail/mods:number"/>
            <if test="string-length($volume)>0">
                <value-of select="concat(' ; ', $volume)"/>
            </if>
        </dcterms:isPartOf>
    </template>

    <template match="mods:relatedItem[@type='series']/mods:identifier[@type='issn']" mode="dcterms:isPartOf">
        <dcterms:isPartOf xsi:type="ddb:ISSN">
            <value-of select="."/>
        </dcterms:isPartOf>
    </template>

    <template match="mods:relatedItem[@type='series']/mods:identifier[@type='urn']" mode="dcterms:isPartOf">
        <dcterms:isPartOf xsi:type="dcterms:URI">
            <value-of select="concat('http://nbn-resolving.de/', .)"/>
        </dcterms:isPartOf>
    </template>

    <template match="mods:relatedItem[@type='host']/mods:identifier[contains(@type, 'urn') or @type='issn']" mode="ZS-TitelID">
        <if test="$document_type='issue'">
            <dcterms:isPartOf xsi:type="ddb:ZSTitelID">
                <value-of select="."/>
            </dcterms:isPartOf>
        </if>
    </template>

    <template match="mods:relatedItem[@type='host']//mods:identifier[@type='zdb']" mode="dcterms:isPartOf">
        <dcterms:isPartOf xsi:type="ddb:Erstkat-ID">
            <value-of select="."/>
        </dcterms:isPartOf>
    </template>

    <template match="mods:relatedItem[@type='host']/mods:relatedItem[@type='host']/mods:identifier[contains(@type, 'urn')]" mode="dcterms:isPartOf">
        <dcterms:isPartOf xsi:type="ddb:ZSTitelID">
            <value-of select="."/>
        </dcterms:isPartOf>
    </template>

    <template match="mods:language/mods:languageTerm[@authority='iso639-2b' and @type='code']">
        <dc:language xsi:type="dcterms:ISO639-2">
            <value-of select="."/>
        </dc:language>
    </template>

    <template match="mods:identifier[@type='qucosa:urn']" mode="dc:identifier">
        <dc:identifier xsi:type="urn:nbn">
            <value-of select="."/>
        </dc:identifier>
    </template>

    <template match="mods:identifier[@type]" mode="ddb:identifier">
        <variable name="ddbtype">
            <choose>
                <when test="@type='swb-ppn'">Erstkat-ID</when>
                <when test="contains(@type, 'urn')">URN</when>
                <otherwise/>
            </choose>
        </variable>
        <if test="string-length($ddbtype)>0">
            <ddb:identifier ddb:type="{$ddbtype}">
                <value-of select="."/>
            </ddb:identifier>
        </if>
    </template>

    <template match="mods:identifier[@type='isbn']" mode="dc:source">
        <dc:source xsi:type="ddb:ISBN">
            <value-of select="."/>
        </dc:source>
    </template>

    <template match="slub:vgwortOpenKey" mode="ddb:identifier">
        <ddb:identifier ddb:type="VG-Wort-Pixel">
            <value-of select="."/>
        </ddb:identifier>
    </template>

    <template match="slub:info[slub:collections/slub:collection='nonOA']" mode="dc:rights">
        <dc:rights xsi:type="ddb:noScheme">info:eu-repo/semantics/restrictedAccess</dc:rights>
    </template>

    <template match="slub:info[not(slub:collections/slub:collection = 'nonOA')]" mode="dc:rights">
        <dc:rights xsi:type="ddb:noScheme">info:eu-repo/semantics/openAccess</dc:rights>
    </template>

    <template match="slub:info" mode="dc:relation">
        <variable name="Funder" select="./slub:juristiction"/>
        <variable name="FundingProgram" select="./slub:funding"/>
        <variable name="ProjectID" select="./slub:project/@uid"/>
        <if test="$Funder != '' and $FundingProgram != '' and $ProjectID != ''">
            <dc:relation xsi:type="ddb:noScheme">
                info:eu-repo/grantAgreement/<value-of select="$Funder"/>/<value-of select="$FundingProgram"/>/<value-of
                    select="$ProjectID"/>
            </dc:relation>
        </if>
    </template>

    <!-- eat all unmatched text content -->

    <template match="text()"/>

    <!-- Helper functions and templates -->

    <function name="myfunc:formatDateTime" as="xs:string">
        <param name="value" as="xs:string"/>
        <choose>
            <when test="contains($value, 'T')">
                <value-of select="format-dateTime(xs:dateTime(myfunc:formatTimezoneHour($value)), '[Y0001]-[M01]-[D01]')"/>
            </when>
            <when test="matches($value, '^\d{4}(-\d{2}){2}$')">
                <value-of select="format-date(xs:date($value), '[Y0001]-[M01]-[D01]')"/>
            </when>
            <when test="matches($value, '^\[\d{4}\]$')">
                <value-of select="replace($value, '[\[\]]', '')"/>
            </when>
            <otherwise>
                <value-of select="$value" />
            </otherwise>
        </choose>
    </function>

    <function name="myfunc:formatTimezoneHour" as="xs:string">
        <param name="value" as="xs:string"/>
        <choose>
            <when test="matches($value, '[+|-]\d{4}$')">
                <variable name="a" select="substring($value, 1, string-length($value)-2)"/>
                <variable name="b" select="substring($value, string-length($value)-1)"/>
                <value-of select="concat($a, ':', $b)"/>
            </when>
            <otherwise>
                <value-of select="$value"/>
            </otherwise>
        </choose>
    </function>

    <template name="elementLanguageAttributeWithFallback">
        <attribute name="lang">
            <choose>
                <!-- If element has @lang attribute use its value -->
                <when test="string(@lang)">
                    <value-of select="@lang"/>
                </when>
                <!-- If the element has no @lang attribute fallback to first mods:languageTerm element -->
                <when test="../mods:language/mods:languageTerm[@authority='iso639-2b']">
                    <value-of select="../mods:language/mods:languageTerm[@authority='iso639-2b'][1]"/>
                </when>
                <!-- If there is no language code obtainable, end transformation with error -->
                <otherwise>
                    <message terminate="yes" xml:space="preserve">ERROR: No @lang attribute in selected element and no mods:language/mods:languageTerm element found.</message>
                </otherwise>
            </choose>
        </attribute>
    </template>

    <template name="thesisDegreeElement">
        <param name="type"/>
        <if test="contains($type, '_thesis')">
            <thesis:degree>
                <thesis:level>
                    <value-of select="myfunc:thesisLevel($type)"/>
                </thesis:level>
                <for-each select="mods:name[@type='corporate' and (
                     mods:role/mods:roleTerm[@type='code' and .='pbl'] or
                     mods:role/mods:roleTerm[@type='code' and .='dgg'])]">
                    <thesis:grantor xsi:type="cc:Corporate">
                        <cc:universityOrInstitution>
                            <cc:name>
                                <value-of select="mods:namePart"/>
                            </cc:name>
                            <apply-templates
                                    select="myfunc:referencingSlubCorporationElement(., @ID)"
                                    mode="thesis:grantor"/>
                        </cc:universityOrInstitution>
                    </thesis:grantor>
                </for-each>
            </thesis:degree>
        </if>
    </template>

    <template match="slub:corporation" mode="thesis:grantor">
        <cc:place>
            <value-of select="@place"/>
        </cc:place>
        <if test="slub:faculty|slub:department">
            <cc:department>
                <for-each select="slub:faculty|slub:department">
                    <cc:name>
                        <value-of select="."/>
                    </cc:name>
                </for-each>
            </cc:department>
        </if>
    </template>

    <!-- Named templates -->

    <template name="ddb:rights">
        <choose>
            <when test="//slub:info/slub:collections[slub:collection='nonOA']">
                <ddb:rights ddb:kind="domain"/>
            </when>
            <otherwise>
                <ddb:rights ddb:kind="free"/>
            </otherwise>
        </choose>
    </template>

    <template name="sourceCitation">
        <param name="documentType"/>
        <param name="isbn"/>
        <param name="issn"/>
        <param name="issue"/>
        <param name="pagesEnd"/>
        <param name="pagesStart"/>
        <param name="publisher"/>
        <param name="publisherPlace"/>
        <param name="subTitle"/>
        <param name="title"/>
        <param name="volume"/>
        <param name="year"/>

        <choose>
            <when test="$documentType='article'">
                <variable name="volume-issue">
                    <if test="string-length($volume)>0">
                        <value-of select="$volume"/>
                    </if>
                    <if test="string-length($issue)>0">
                        <value-of select="concat('(', $issue, ')')"/>
                    </if>
                </variable>
                <variable name="pages">
                    <if test="string-length($pagesStart)>0">
                        <value-of select="concat('S. ', string-join(($pagesStart, $pagesEnd)[.!=''], '-'))"/>
                    </if>
                </variable>
                <variable name="volume-issue-pages" select="string-join(($volume-issue, $pages)[.!=''], ',')"/>
                <variable name="_issn">
                    <if test="string-length($issn)">
                        <value-of select="concat('ISSN: ', $issn)"/>
                    </if>
                </variable>
                <value-of select="string-join(($title, $volume-issue-pages, $_issn)[.!=''], '. ')"/>
            </when>

            <when test="matches($documentType, 'in_proceeding|contained_work|in_book')">
                <variable name="title-subtitle" select="string-join(($title, $subTitle)[.!=''], ' : ')"/>
                <variable name="place-publisher" select="string-join(($publisherPlace, $publisher)[.!=''], ' : ')"/>
                <variable name="place-publisher-year" select="string-join(($place-publisher, $year)[.!=''], ', ')"/>
                <variable name="pages">
                    <if test="string-length($pagesStart)>0">
                        <value-of select="concat('S. ', string-join(($pagesStart, $pagesEnd)[.!=''], '-'))"/>
                    </if>
                </variable>
                <variable name="_isbn">
                    <if test="string-length($isbn)">
                        <value-of select="concat('ISBN: ', $isbn)"/>
                    </if>
                </variable>
                <value-of select="string-join(($title-subtitle, $place-publisher-year, $pages, $_isbn)[.!=''], '. ')"/>
            </when>

            <otherwise>
                <value-of select="string-join(($title, $publisher, $year)[.!=''], '. ')"/>
            </otherwise>
        </choose>
    </template>

    <!--
        XSLT Mapping functions
    -->

    <function name="myfunc:thesisRole" as="xs:string">
        <param name="role"/>
        <choose>
            <when test="$role = 'edt'">editor</when>
            <when test="$role = 'rev'">referee</when>
            <when test="$role = 'sad'">advisor</when>
            <when test="$role = 'ths'">advisor</when>
            <when test="$role = 'pbl'">editor</when>
            <when test="$role = 'dgs'">advisor</when>
            <otherwise>error</otherwise>
        </choose>
    </function>

    <function name="myfunc:thesisLevel" as="xs:string">
        <param name="type"/>
        <choose>
            <when test="$type = 'bachelor_thesis'">bachelor</when>
            <when test="$type = 'diploma_thesis'">Diplom</when>
            <when test="$type = 'doctoral_thesis'">thesis.doctoral</when>
            <when test="$type = 'habilitation_thesis'">thesis.habilitation</when>
            <when test="$type = 'master_thesis'">master</when>
            <when test="$type = 'magister_thesis'">M.A.</when>
            <otherwise>other</otherwise>
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
            <when test="$type = 'master_thesis'">masterThesis</when>
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
                Type `in_book` has been renamed to `contained_work`, but some older documents might have `in_book`.
            -->
            <when test="$type = 'in_book'">bookPart</when>

            <!--
                Types `multivolume_work` and `text` are not defined for DINI and are mapped to `Other`
             -->
            <otherwise>Other</otherwise>
        </choose>
    </function>

    <function name="myfunc:referencingSlubCorporationElement">
        <param name="context"/>
        <param name="refid" as="xs:string"/>
        <sequence select="root($context)//slub:corporation[
            @ref=$refid or @ref=concat('#', $refid) or @slub:ref=$refid or @slub:ref=concat('#', $refid)]"/>
    </function>

    <function name="myfunc:nodesMatch" as="xs:boolean">
        <param name="nodes"/>
        <param name="pattern" as="xs:string"/>
        <sequence select="matches(string-join($nodes, ' '), $pattern)"/>
    </function>

</stylesheet>
