<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns="http://opcfoundation.org/UA/2011/03/UANodeSet.xsd" 
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		xsi:noNamespaceSchemaLocation="CAEX_ClassModel_V2.15.xsd" 
		exclude-result-prefixes="#default xsi xsl exslt"
		xmlns:exslt="http://exslt.org/common">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
		
	<!-- .........................................................................
		Library parsing
	.........................................................................-->
	<!-- ________________________________________________________________________________________________ -->
	<xsl:variable name="Libraries">
		<_libraries>
		<xsl:copy-of select="//*[name()='SystemUnitClassLib' and count(preceding-sibling::*[@Name=current()/@Name])=0]"/>
		<xsl:copy-of select="//*[name()='RoleClassLib' and count(preceding-sibling::*[@Name=current()/@Name])=0]"/>
		<xsl:copy-of select="//*[name()='InterfaceClassLib' and count(preceding-sibling::*[@Name=current()/@Name])=0]"/>
		</_libraries>
	</xsl:variable>
	<!-- ________________________________________________________________________________________________ -->
	<xsl:template name="GetSubClass">
		<xsl:param name="search"/>
		<xsl:param name="input"/>
		<xsl:choose>
			<xsl:when test="contains($search, '/')">
				<xsl:variable name="parentclass" select="substring-before($search,'/')"/>
				<xsl:variable name="subclass" select="substring-after($search,'/')"/>
				<xsl:if test="exslt:node-set($input)/*[(name()='SystemUnitClass' or name()='RoleClass' or name()='InterfaceClass') and @Name=$parentclass]">
					<xsl:call-template name="GetSubClass">
						<xsl:with-param name="search" select="$subclass"/>
						<xsl:with-param name="input">
							<xsl:copy-of select="exslt:node-set($input)/*[(name()='SystemUnitClass' or name()='RoleClass' or name()='InterfaceClass') and @Name=$parentclass]/*"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="exslt:node-set($input)//*[(name()='RoleClass' or name()='SystemUnitClass' or name()='InterfaceClass') and @Name=$search]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ________________________________________________________________________________________________ -->
	<xsl:template name="GetClass">
		<xsl:param name="path"/>
		<xsl:variable name="libName" select="substring-before($path,'/')"/>
		<xsl:variable name="subPath" select="substring-after($path,'/')"/>
		
		<xsl:variable name="currentClass">
			<xsl:choose>
				<xsl:when test="$libName!= '' and exslt:node-set($Libraries)//RoleClassLib[@Name=$libName]!=''">
					<xsl:call-template name="GetSubClass">
						<xsl:with-param name="search" select="$subPath"/>
						<xsl:with-param name="input">
							<xsl:copy-of select="exslt:node-set($Libraries)//RoleClassLib[@Name=$libName]/RoleClass"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$libName!='' and exslt:node-set($Libraries)//SystemUnitClassLib[@Name=$libName]!=''">
					<xsl:call-template name="GetSubClass">
						<xsl:with-param name="search" select="$subPath"/>
						<xsl:with-param name="input">
							<xsl:copy-of select="exslt:node-set($Libraries)//SystemUnitClassLib[@Name=$libName]/SystemUnitClass"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$libName!='' and exslt:node-set($Libraries)//RoleClassLib[@Name=$libName]!=''">
					<xsl:call-template name="GetSubClass">
						<xsl:with-param name="search" select="$subPath"/>
						<xsl:with-param name="input">
							<xsl:copy-of select="exslt:node-set($Libraries)//RoleClassLib[@Name=$libName]/SystemUnitClass"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$libName!='' and exslt:node-set($Libraries)//InterfaceClassLib[@Name=$libName]!=''">
					<xsl:call-template name="GetSubClass">
						<xsl:with-param name="search" select="$subPath"/>
						<xsl:with-param name="input">
							<xsl:copy-of select="exslt:node-set($Libraries)//InterfaceClassLib[@Name=$libName]/InterfaceClass"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="exslt:node-set($currentClass)/*[1]/@RefBaseClassPath!=''">
				<xsl:variable name="baseClass">
					<xsl:choose>
						<xsl:when test="contains(exslt:node-set($currentClass)/*[1]/@RefBaseClassPath, '/')">
							<xsl:call-template name="GetClass">
								<xsl:with-param name="path">
									<xsl:value-of select="exslt:node-set($currentClass)/*[1]/@RefBaseClassPath"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="removePath" select="concat('/', exslt:node-set($currentClass)/*[1]/@Name)"/>
							<xsl:variable name="basePath" select="substring-before($path, $removePath)"/>
							<xsl:call-template name="GetClass">
								<xsl:with-param name="path" select="$basePath"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:for-each select="exslt:node-set($currentClass)/*[1]">
					<xsl:copy>
						<xsl:copy-of select="@*"/>
						<xsl:copy-of select="Attribute"/>
						<xsl:copy-of select="exslt:node-set($baseClass)/*/Attribute"/>
					</xsl:copy>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="exslt:node-set($currentClass)/*[1]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ________________________________________________________________________________________________ -->

	<!-- .........................................................................
		Unknown Elements: Ignore
	.........................................................................-->
	<xsl:template match="text()"/>

</xsl:stylesheet>
