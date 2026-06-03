from pathlib import Path
from saxonche import PySaxonProcessor
from lxml import etree

outdir = Path("OPC_UA")
outdir.mkdir(exist_ok=True)

ns = {
    "uax": "http://opcfoundation.org/UA/2008/02/Types.xsd"
}

with PySaxonProcessor(license=False) as proc:
    xslt = proc.new_xslt30_processor()

    for aml in Path("AML").glob("*.aml"):
        outfile = outdir / f"{aml.stem}.xml"

        xslt.transform_to_file(
            source_file=str(aml),
            stylesheet_file="../AML2Nodeset.xslt",
            output_file=str(outfile)
        )

        # Unbenutzte Namespaces entfernen
        tree = etree.parse(str(outfile))
        etree.cleanup_namespaces(tree.getroot())

        # uax:String-Inhalte als CDATA schreiben
        for node in tree.xpath("//uax:String", namespaces=ns):
            if node.text and node.text.lstrip().startswith("<"):
                node.text = etree.CDATA(node.text)

        tree.write(
            str(outfile),
            encoding="utf-8",
            xml_declaration=True,
            pretty_print=True
        )