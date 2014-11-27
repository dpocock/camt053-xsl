<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (C) 2012, Daniel Pocock http://danielpocock.com -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:camt="urn:iso:std:iso:20022:tech:xsd:camt.053.001.02">
<xsl:output method="text" encoding="UTF-8"/>

<xsl:strip-space elements="*" />

<xsl:template match="/camt:Document/camt:BkToCstmrStmt/camt:GrpHdr">
  <xsl:if test="camt:MsgPgntn/camt:PgNb != 1 or camt:MsgPgntn/camt:LastPgInd != 'true'">
    <xsl:message terminate="yes">
      <xsl:text>Incomplete message (not first page or subsequent pages exist)</xsl:text>
    </xsl:message>
  </xsl:if>
</xsl:template>

<xsl:template match="/camt:Document/camt:BkToCstmrStmt/camt:Stmt">
<xsl:for-each select="camt:Ntry">
<xsl:value-of select="camt:BookgDt/camt:Dt"/>,<xsl:value-of select="camt:ValDt/camt:Dt"/>,"<xsl:value-of select="camt:AcctSvcrRef"/>","<xsl:value-of select="camt:AddtlNtryInf"/>",<xsl:if test="camt:CdtDbtInd != 'CRDT'">-</xsl:if><xsl:value-of select="camt:Amt"/><xsl:text>&#xD;&#xA;</xsl:text>
</xsl:for-each>
</xsl:template>

<xsl:template match="/"><xsl:apply-templates select="/camt:Document/camt:BkToCstmrStmt/camt:GrpHdr|/camt:Document/camt:BkToCstmrStmt/camt:Stmt"/></xsl:template>

</xsl:stylesheet>
