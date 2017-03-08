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

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mets="http://www.loc.gov/METS/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xMetaDiss="http://www.d-nb.de/standards/xmetadissplus/"
                xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd
                                    http://www.d-nb.de/standards/xmetadissplus/ http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd">

    <xsl:output standalone="yes" encoding="utf-8" media-type="application/xml" indent="yes" method="xml"/>

    <xsl:template match="/mets:mets">
        <xsl:element name="xMetaDiss:xMetaDiss">

        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
