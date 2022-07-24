<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (C) 2012, Daniel Pocock http://danielpocock.com -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="UTF-8"/>

<xsl:strip-space elements="*" />

<xsl:template match="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'GrpHdr']">
  <xsl:if test="*[local-name() = 'MsgPgntn']/*[local-name() = 'PgNb'] != 1 or *[local-name() = 'MsgPgntn']/*[local-name() = 'LastPgInd'] != 'true'">
    <xsl:message terminate="yes">
      <xsl:text>Incomplete message (not first page or subsequent pages exist)</xsl:text>
    </xsl:message>
  </xsl:if>
</xsl:template>

<xsl:template match="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'Stmt']">
<xsl:for-each select="*[local-name() = 'Ntry']">
<xsl:value-of select="*[local-name() = 'BookgDt']/*[local-name() = 'Dt']"/>,<xsl:value-of select="*[local-name() = 'ValDt']/*[local-name() = 'Dt']"/>,"<xsl:value-of select="*[local-name() = 'AcctSvcrRef']"/>","<xsl:value-of select="*[local-name() = 'AddtlNtryInf']"/>",<xsl:if test="*[local-name() = 'CdtDbtInd'] != 'CRDT'">-</xsl:if><xsl:value-of select="*[local-name() = 'Amt']"/><xsl:text>&#xD;&#xA;</xsl:text>
</xsl:for-each>
</xsl:template>

<xsl:template match="/"><xsl:apply-templates select="/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'GrpHdr']|/*[local-name() = 'Document']/*[local-name() = 'BkToCstmrStmt']/*[local-name() = 'Stmt']"/></xsl:template>

</xsl:stylesheet>
