# Qucosa Fedora XMetaDissPlus Dissemination

A web service disseminating xMetaDissPlus documents based on METS format disseminations.

# Usage

The service has one parameter `metsurl` which is the location of a Qucosa METS-Document. It will fetch METS XML from
this location and transform it into XMetaDissPlus XML.

Example: `http://localhost:8080/xmetadissplus?metsurl=http://some.host/mets.xml`

# Licence

The program is licenced under [Apache License Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
