<?xml version="1.0" encoding="UTF-8"?>

<!-- Copyright (C) 2012, Daniel Pocock http://danielpocock.com -->

<!-- Note:
       It is necessary to tweak the camt 053 namespace version in
       the xmlns:camt definition below to match the exact version used
       in the input document, e.g. for Postfinance Switzerland, you
       may need to use
         xmlns:camt="urn:iso:std:iso:20022:tech:xsd:camt.053.001.02"
       and for the ISO 20022 sample document use
         xmlns:camt="urn:iso:std:iso:20022:tech:xsd:camt.053.001.04"
  -->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">
  <xsl:output method="xml" encoding="UTF-8"/>

  <!-- Look at the file's GrpHdr -->
  <xsl:template match="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'GrpHdr']">
    <!-- Check if the camt 053 statement is contained within a single file/message
         We don't handle statements split into multiple files yet
         and if one is encountered, the translation will be aborted -->
    <xsl:if test="*[local-name() = 'MsgPgntn']/*[local-name() = 'PgNb'] != 1 or *[local-name() = 'MsgPgntn']/*[local-name() = 'LastPgInd'] != 'true'">
      <xsl:message terminate="yes">
        <xsl:text>Incomplete message (not first page or subsequent pages exist)</xsl:text>
      </xsl:message>
    </xsl:if>
  </xsl:template>

  <!-- Handle one of the summary rows (opening or closing balance details) -->
  <xsl:template match="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'Stmt']/*[local-name() = 'Bal']">
    <fo:table-row>
      <fo:table-cell>
        <fo:block font-weight="bold">
          <xsl:choose>
            <xsl:when test="*[local-name() = 'Tp']/*[local-name() = 'CdOrPrtry']/*[local-name() = 'Cd'] = 'OPBD'">Opening</xsl:when>
            <xsl:when test="*[local-name() = 'Tp']/*[local-name() = 'CdOrPrtry']/*[local-name() = 'Cd'] = 'CLBD'">Closing</xsl:when>
            <xsl:otherwise>-</xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell>
        <fo:block>
          <xsl:value-of select="*[local-name() = 'Dt']/*[local-name() = 'Dt']"/><xsl:if test="*[local-name() = 'Tp']/*[local-name() = 'CdOrPrtry']/*[local-name() = 'Cd'] = 'OPBD'">&#160;(+1)</xsl:if>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell text-align="right">
        <fo:block><xsl:if test="*[local-name() = 'CdtDbtInd'] != 'CRDT'">-</xsl:if><xsl:value-of select="*[local-name() = 'Amt']"/></fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <!-- Handle one of the entries in the list of transactions -->
  <xsl:template match="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'Stmt']/*[local-name() = 'Ntry']">
    <fo:table-row>
      <fo:table-cell>
        <fo:block><xsl:value-of select="*[local-name() = 'BookgDt']/*[local-name() = 'Dt']"/></fo:block>
      </fo:table-cell>
      <fo:table-cell>
        <fo:block><xsl:value-of select="*[local-name() = 'ValDt']/*[local-name() = 'Dt']"/></fo:block>
      </fo:table-cell>
      <fo:table-cell>
        <fo:block><xsl:value-of select="*[local-name() = 'AcctSvcrRef']"/></fo:block>
        <fo:block><xsl:value-of select="*[local-name() = 'NtryDtls']/*[local-name() = 'TxDtls']/*[local-name() = 'RltdPties']/camt:*/*[local-name() = 'Nm']"/></fo:block>
        <fo:block><xsl:value-of select="*[local-name() = 'AddtlNtryInf']"/></fo:block>
      </fo:table-cell>
      <fo:table-cell text-align="right">
        <fo:block><xsl:if test="*[local-name() = 'CdtDbtInd'] = 'CRDT'"><xsl:value-of select="*[local-name() = 'Amt']"/></xsl:if></fo:block>
      </fo:table-cell>
      <fo:table-cell text-align="right">
        <fo:block><xsl:if test="*[local-name() = 'CdtDbtInd'] = 'DBIT'"><xsl:value-of select="*[local-name() = 'Amt']"/></xsl:if></fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <!-- Handle the root node of the XML document -->
  <xsl:template match="/">
    <!-- Check the GrpHdr first -->
    <xsl:apply-templates select="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'GrpHdr']"/>

    <!-- Start generating an XSL-FO document -->
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">

      <fo:layout-master-set>
        <fo:simple-page-master
                master-name="A4"
                page-width="210mm"
                page-height="297mm"
                margin-top="1.5cm"
                margin-bottom="1.5cm"
                margin-left="1.5cm"
                margin-right="1.5cm">
          <fo:region-body margin-top="1.5cm" margin-bottom="1.5cm"/>
          <fo:region-before extent="1.2cm"/>
          <fo:region-after extent="1.2cm"/>
        </fo:simple-page-master>
      </fo:layout-master-set>

      <fo:page-sequence master-reference="A4" id="end">

        <!-- Header for every page -->
        <fo:static-content flow-name="xsl-region-before">
          <fo:block font-size="9pt" font-family="sans-serif">
            <!-- Account number and currency -->
            <xsl:value-of select="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'Stmt']/*[local-name() = 'Acct']/*[local-name() = 'Id']"/>
              (<xsl:value-of select="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'Stmt']/*[local-name() = 'Bal']/*[local-name() = 'Amt']/@Ccy"/>)
          </fo:block>
          <fo:block font-size="9pt" font-family="sans-serif">
            <!-- Account holder name -->
            <xsl:value-of select="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'Stmt']/*[local-name() = 'Acct']/*[local-name() = 'Ownr']/*[local-name() = 'Nm']"/>
          </fo:block>
        </fo:static-content>

        <!-- Footer for every page -->
        <fo:static-content flow-name="xsl-region-after">
          <!-- Page count -->
          <fo:block text-align="center" font-size="9pt" font-family="sans-serif">
            Page <fo:page-number/> of <fo:page-number-citation-last ref-id="end"/>
          </fo:block>
        </fo:static-content>

        <fo:flow flow-name="xsl-region-body">

          <!-- Summary of opening and closing dates and balances -->
          <fo:block font-style="italic" font-size="12pt" font-family="sans-serif">Summary</fo:block>

          <fo:block padding-top="3mm" font-size="9pt" font-family="sans-serif">
            <fo:table>
              <fo:table-column column-width="20mm"/>
              <fo:table-column column-width="20mm"/>
              <fo:table-column column-width="40mm"/>

              <fo:table-header>
                <fo:table-row>
                  <fo:table-cell>
                    <fo:block font-weight="bold"></fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block font-weight="bold">Date</fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block font-weight="bold" text-align="right">Balance</fo:block>
                  </fo:table-cell>
                </fo:table-row>
              </fo:table-header>
              <fo:table-body>
                <xsl:apply-templates select="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'Stmt']/*[local-name() = 'Bal']/*[local-name() = 'Tp']/*[local-name() = 'CdOrPrtry']/*[local-name() = 'Cd'][text()='OPBD']/../../.."/>
                <xsl:apply-templates select="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'Stmt']/*[local-name() = 'Bal']/*[local-name() = 'Tp']/*[local-name() = 'CdOrPrtry']/*[local-name() = 'Cd'][text()='CLBD']/../../.."/>
              </fo:table-body>

            </fo:table>
          </fo:block>

          <!-- List of transaction details -->
          <fo:block font-style="italic" font-size="12pt" font-family="sans-serif" padding-top="5mm" >Transactions</fo:block>

          <fo:block padding-top="3mm" font-size="9pt" font-family="sans-serif">
            <xsl:choose>
              <xsl:when test="count(/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'Stmt']/*[local-name() = 'Ntry']) = 0">
                <fo:block font-style="italic" text-align="center">No entries booked in this period</fo:block>
              </xsl:when>
              <xsl:otherwise>
                <fo:table>
                  <fo:table-column column-width="20mm"/> <!-- Booking date -->
                  <fo:table-column column-width="20mm"/> <!-- Value date -->
                  <fo:table-column />                    <!-- Details -->
                  <fo:table-column column-width="20mm"/> <!-- Credit -->
                  <fo:table-column column-width="20mm"/> <!-- Debit -->

                  <fo:table-header>
                    <fo:table-row>
                      <fo:table-cell>
                        <fo:block font-weight="bold">Booking Date</fo:block>
                      </fo:table-cell>
                      <fo:table-cell>
                        <fo:block font-weight="bold">Value Date</fo:block>
                      </fo:table-cell>
                      <fo:table-cell>
                        <fo:block font-weight="bold">Details</fo:block>
                      </fo:table-cell>
                      <fo:table-cell>
                        <fo:block font-weight="bold" text-align="right">Credit</fo:block>
                      </fo:table-cell>
                      <fo:table-cell>
                        <fo:block font-weight="bold" text-align="right">Debit</fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                  </fo:table-header>

                  <fo:table-body>
                    <xsl:apply-templates select="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'Stmt']/*[local-name() = 'Ntry']"/>
                  </fo:table-body>

                </fo:table>
              </xsl:otherwise>
            </xsl:choose>
          </fo:block>
        </fo:flow>
      </fo:page-sequence>

    </fo:root>
  </xsl:template>

</xsl:stylesheet>
