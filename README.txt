
Introduction
------------

This project provides some XSL files for working with bank statements
published using the camt 053 XML file format.

 * camt2pdf.xsl converts the bank statement to a PDF for printing
 * camt2csv.xsl converts the bank statement to a CSV file for
   use with a spreadsheet

camt 053 defines the message named BankToCustomerStatementV04

How to use
----------

GNU/Linux users can install the xsltproc and fop utilities.
On Debian and Ubuntu, the package names are xsltproc and fop,

  $ sudo apt-get install xsltproc fop

The xsltproc utility transforms the bank statement into an XSL-FO XML file
describing the print layout.  The fop utility transforms the XSL-FO file
into PDF or another output format (see the man page for details).

Here is an example of how to generate a PDF:

  $ xsltproc camt2pdf.xsl statement.xml | fop - statement.pdf

and here is an example to convert camt 053 to CSV:

  $ xsltproc camt2csv.xsl statement.xml > statement.csv

Known issues
------------

Different banks may use slightly different versions of the camt 053
specification.  The exact version is specified in the xmlns attribute
in the XML file itself.

For example, Swiss Postfinance sends camt 053 XML files containing the
following:

  <Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.053.001.02"
   ...

while the sample document from the ISO 20022 web site contains this:

  <Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.053.001.04"
   ...

The exact same namespace string must be used in the xmlns:camt line
of the XSL files.  To use camt2pdf.xsl with an XML from Postfinance,
change the line near the top of camt2pdf.xsl to read:

  <xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:camt="urn:iso:std:iso:20022:tech:xsd:camt.053.001.02">

If you see an error like this when converting to PDF:

Exception
org.apache.fop.apps.FOPException:
  org.apache.fop.fo.ValidationException:
   "fo:table-body" is missing child elements.
   Required content model: marker* (table-row+|table-cell+)
       (See position 5:747)

it may be that the bank statement XML is invalid, or the xmlns did not
match.

More details and related free software projects
-----------------------------------------------

 * http://www.iso20022.org/payments_messages.page
 * http://en.wikipedia.org/wiki/ISO_20022
 * http://project.i20022.com/
 * http://www.c24.biz/

Copyright and license information
---------------------------------

Copyright (C) 2012-2014, Daniel Pocock http://danielpocock.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

