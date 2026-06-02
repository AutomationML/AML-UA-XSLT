from pathlib import Path
from lxml import etree

xslt = etree.XSLT(etree.parse("../AML2Nodeset.xslt"))

for aml in Path("UnitTests/AML").glob("*.aml"):
    result = xslt(etree.parse(str(aml)))
    Path("UnitTests/OPC_UA").mkdir(exist_ok=True)
    result.write_output(str(Path("UnitTests/OPC_UA") / f"{aml.stem}.xml"))