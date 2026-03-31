//
//  PPTXExportService.swift
//  Pitch Me
//
//  🔥 Real PowerPoint export — pure Swift Open XML, no backend needed 🔥
//  Generates .pptx files from Deck data using the OOXML spec
//

import Foundation
import UIKit

// MARK: - PPTX Export Service

final class PPTXExportService {
    static let shared = PPTXExportService()
    private init() {}

    // MARK: - Public Entry Point

    func exportToPPTX(_ deck: Deck) throws -> URL {
        let builder = PPTXBuilder(deck: deck)
        let data = try builder.build()

        let fileName = sanitizeFileName(deck.title) + ".pptx"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: tempURL)
        print("✅ PPTX exported: \(tempURL.path) (\(data.count / 1024) KB)")
        return tempURL
    }

    private func sanitizeFileName(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\:*?\"<>|")
        return name.components(separatedBy: invalid).joined(separator: "-")
    }
}

// MARK: - PPTX Builder

private final class PPTXBuilder {
    let deck: Deck

    init(deck: Deck) {
        self.deck = deck
    }

    // MARK: - Build ZIP

    func build() throws -> Data {
        var files: [String: Data] = [:]

        // Required OOXML parts
        files["[Content_Types].xml"]          = contentTypes().utf8Data
        files["_rels/.rels"]                  = rootRels().utf8Data
        files["ppt/presentation.xml"]         = presentation().utf8Data
        files["ppt/_rels/presentation.xml.rels"] = presentationRels().utf8Data
        files["ppt/slideMasters/slideMaster1.xml"]     = slideMaster().utf8Data
        files["ppt/slideMasters/_rels/slideMaster1.xml.rels"] = slideMasterRels().utf8Data
        files["ppt/slideLayouts/slideLayout1.xml"]     = slideLayout().utf8Data
        files["ppt/slideLayouts/_rels/slideLayout1.xml.rels"] = slideLayoutRels().utf8Data
        files["ppt/theme/theme1.xml"]         = theme().utf8Data

        // Slides
        for (index, slide) in deck.slides.enumerated() {
            let slideNumber = index + 1
            files["ppt/slides/slide\(slideNumber).xml"] = slideXML(slide, index: index).utf8Data
            files["ppt/slides/_rels/slide\(slideNumber).xml.rels"] = slideRels(slideNumber: slideNumber).utf8Data
        }

        return try createZip(files: files)
    }

    // MARK: - Theme Colors

    private var themeColors: (bg: String, text: String, accent: String) {
        switch deck.theme.id {
        case "dark-tech":   return ("1A1A2E", "FFFFFF", "C6F135")
        case "bold-color":  return ("7B2FBE", "FFFFFF", "F7C948")
        case "minimal":     return ("FAFAFA", "111111", "333333")
        default:            return ("FFFFFF", "1A1A1A", "C6F135") // clean-light
        }
    }

    // MARK: - [Content_Types].xml

    private func contentTypes() -> String {
        var overrides = ""
        for i in 1...max(1, deck.slides.count) {
            overrides += """
            <Override PartName="/ppt/slides/slide\(i).xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>
            """
        }
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
          <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
          <Default Extension="xml"  ContentType="application/xml"/>
          <Override PartName="/ppt/presentation.xml"       ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>
          <Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/>
          <Override PartName="/ppt/slideLayouts/slideLayout1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
          <Override PartName="/ppt/theme/theme1.xml"       ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>
          \(overrides)
        </Types>
        """
    }

    // MARK: - _rels/.rels

    private func rootRels() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>
        </Relationships>
        """
    }

    // MARK: - ppt/presentation.xml

    private func presentation() -> String {
        var slideIdList = ""
        for i in 1...max(1, deck.slides.count) {
            slideIdList += "<p:sldId id=\"\(255 + i)\" r:id=\"rId\(i)\"/>"
        }

        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <p:presentation xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
          xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
          xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <p:sldMasterIdLst>
            <p:sldMasterId id="2147483648" r:id="rIdMaster"/>
          </p:sldMasterIdLst>
          <p:sldSz cx="9144000" cy="5143500"/>
          <p:notesSz cx="6858000" cy="9144000"/>
          <p:sldIdLst>\(slideIdList)</p:sldIdLst>
        </p:presentation>
        """
    }

    // MARK: - ppt/_rels/presentation.xml.rels

    private func presentationRels() -> String {
        var slideRelsXML = ""
        for i in 1...max(1, deck.slides.count) {
            slideRelsXML += """
            <Relationship Id="rId\(i)" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide\(i).xml"/>
            """
        }
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          \(slideRelsXML)
          <Relationship Id="rIdMaster" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="slideMasters/slideMaster1.xml"/>
          <Relationship Id="rIdTheme" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/>
        </Relationships>
        """
    }

    // MARK: - Slide XML

    private func slideXML(_ slide: Slide, index: Int) -> String {
        let colors = themeColors
        let bgColor = colors.bg
        let textColor = colors.text
        let accentColor = colors.accent

        // Title
        let titleXML = textBox(
            text: xmlEscape(slide.title),
            x: 457200, y: 274638, cx: 8229600, cy: 1143000,
            fontSize: 3600, bold: true, color: textColor
        )

        // Bullets
        var bulletParagraphs = ""
        for bullet in slide.bullets {
            bulletParagraphs += bulletParagraph(text: xmlEscape(bullet), color: textColor, accentColor: accentColor)
        }
        let bulletsXML = textBoxWithParagraphs(
            paragraphs: bulletParagraphs,
            x: 457200, y: 1600200, cx: 8229600, cy: 3200400
        )

        // Speaker notes
        let notesXML = slide.speakerNotes.map { _ in "" } ?? ""

        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <p:sld xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
               xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
               xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <p:cSld>
            <p:bg>
              <p:bgPr>
                <a:solidFill><a:srgbClr val="\(bgColor)"/></a:solidFill>
                <a:effectLst/>
              </p:bgPr>
            </p:bg>
            <p:spTree>
              <p:nvGrpSpPr>
                <p:cNvPr id="1" name=""/>
                <p:cNvGrpSpPr/>
                <p:nvPr/>
              </p:nvGrpSpPr>
              <p:grpSpPr>
                <a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm>
              </p:grpSpPr>
              \(accentBar(color: accentColor))
              \(slideNumberBadge(number: index + 1, color: accentColor))
              \(titleXML)
              \(bulletsXML)
            </p:spTree>
          </p:cSld>
        </p:sld>
        """
    }

    // MARK: - Accent bar at top

    private func accentBar(color: String) -> String {
        return """
        <p:sp>
          <p:nvSpPr>
            <p:cNvPr id="10" name="AccentBar"/>
            <p:cNvSpPr><a:spLocks noGrp="1"/></p:cNvSpPr>
            <p:nvPr/>
          </p:nvSpPr>
          <p:spPr>
            <a:xfrm><a:off x="0" y="0"/><a:ext cx="9144000" cy="45720"/></a:xfrm>
            <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
            <a:solidFill><a:srgbClr val="\(color)"/></a:solidFill>
            <a:ln><a:noFill/></a:ln>
          </p:spPr>
          <p:txBody><a:bodyPr/><a:lstStyle/><a:p/></p:txBody>
        </p:sp>
        """
    }

    // MARK: - Slide number badge

    private func slideNumberBadge(number: Int, color: String) -> String {
        return """
        <p:sp>
          <p:nvSpPr>
            <p:cNvPr id="11" name="SlideNum"/>
            <p:cNvSpPr txBox="1"><a:spLocks noGrp="1"/></p:cNvSpPr>
            <p:nvPr/>
          </p:nvSpPr>
          <p:spPr>
            <a:xfrm><a:off x="8686800" y="4800600"/><a:ext cx="457200" cy="342900"/></a:xfrm>
            <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
            <a:noFill/>
          </p:spPr>
          <p:txBody>
            <a:bodyPr anchor="ctr"/>
            <a:lstStyle/>
            <a:p>
              <a:pPr algn="r"/>
              <a:r>
                <a:rPr lang="en-US" sz="800" b="0">
                  <a:solidFill><a:srgbClr val="\(color)"/></a:solidFill>
                </a:rPr>
                <a:t>\(number)</a:t>
              </a:r>
            </a:p>
          </p:txBody>
        </p:sp>
        """
    }

    // MARK: - Text Box (title)

    private func textBox(text: String, x: Int, y: Int, cx: Int, cy: Int,
                         fontSize: Int, bold: Bool, color: String) -> String {
        return """
        <p:sp>
          <p:nvSpPr>
            <p:cNvPr id="20" name="Title"/>
            <p:cNvSpPr txBox="1"><a:spLocks noGrp="1"/></p:cNvSpPr>
            <p:nvPr/>
          </p:nvSpPr>
          <p:spPr>
            <a:xfrm><a:off x="\(x)" y="\(y)"/><a:ext cx="\(cx)" cy="\(cy)"/></a:xfrm>
            <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
            <a:noFill/>
          </p:spPr>
          <p:txBody>
            <a:bodyPr wrap="square" lIns="91440" tIns="45720" rIns="91440" bIns="45720"/>
            <a:lstStyle/>
            <a:p>
              <a:r>
                <a:rPr lang="en-US" sz="\(fontSize)" b="\(bold ? 1 : 0)" dirty="0">
                  <a:solidFill><a:srgbClr val="\(color)"/></a:solidFill>
                  <a:latin typeface="+mj-lt"/>
                </a:rPr>
                <a:t>\(text)</a:t>
              </a:r>
            </a:p>
          </p:txBody>
        </p:sp>
        """
    }

    // MARK: - Text Box with multiple paragraphs (bullets)

    private func textBoxWithParagraphs(paragraphs: String, x: Int, y: Int, cx: Int, cy: Int) -> String {
        return """
        <p:sp>
          <p:nvSpPr>
            <p:cNvPr id="21" name="Content"/>
            <p:cNvSpPr txBox="1"><a:spLocks noGrp="1"/></p:cNvSpPr>
            <p:nvPr/>
          </p:nvSpPr>
          <p:spPr>
            <a:xfrm><a:off x="\(x)" y="\(y)"/><a:ext cx="\(cx)" cy="\(cy)"/></a:xfrm>
            <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
            <a:noFill/>
          </p:spPr>
          <p:txBody>
            <a:bodyPr wrap="square" lIns="91440" tIns="45720" rIns="91440" bIns="45720"/>
            <a:lstStyle/>
            \(paragraphs)
          </p:txBody>
        </p:sp>
        """
    }

    // MARK: - Bullet paragraph

    private func bulletParagraph(text: String, color: String, accentColor: String) -> String {
        return """
        <a:p>
          <a:pPr marL="342900" indent="-342900">
            <a:buClr><a:srgbClr val="\(accentColor)"/></a:buClr>
            <a:buChar char="•"/>
          </a:pPr>
          <a:r>
            <a:rPr lang="en-US" sz="1800" b="0" dirty="0">
              <a:solidFill><a:srgbClr val="\(color)"/></a:solidFill>
              <a:latin typeface="+mn-lt"/>
            </a:rPr>
            <a:t>\(text)</a:t>
          </a:r>
        </a:p>
        """
    }

    // MARK: - Slide rels

    private func slideRels(slideNumber: Int) -> String {
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>
        </Relationships>
        """
    }

    // MARK: - Slide Master (minimal)

    private func slideMaster() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <p:sldMaster xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
                     xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                     xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <p:cSld><p:spTree>
            <p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>
            <p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>
          </p:spTree></p:cSld>
          <p:clrMap bg1="lt1" tx1="dk1" bg2="lt2" tx2="dk2" accent1="acc1" accent2="acc2" accent3="acc3" accent4="acc4" accent5="acc5" accent6="acc6" hlink="hlink" folHlink="folHlink"/>
          <p:sldLayoutIdLst>
            <p:sldLayoutId id="2147483649" r:id="rId1"/>
          </p:sldLayoutIdLst>
          <p:txStyles>
            <p:titleStyle><a:lvl1pPr><a:defRPr lang="en-US"/></a:lvl1pPr></p:titleStyle>
            <p:bodyStyle><a:lvl1pPr><a:defRPr lang="en-US"/></a:lvl1pPr></p:bodyStyle>
            <p:otherStyle><a:lvl1pPr><a:defRPr lang="en-US"/></a:lvl1pPr></p:otherStyle>
          </p:txStyles>
        </p:sldMaster>
        """
    }

    private func slideMasterRels() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>
          <Relationship Id="rIdTheme" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="../theme/theme1.xml"/>
        </Relationships>
        """
    }

    // MARK: - Slide Layout (minimal blank)

    private func slideLayout() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <p:sldLayout xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
                     xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                     xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                     type="blank">
          <p:cSld name="Blank"><p:spTree>
            <p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>
            <p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>
          </p:spTree></p:cSld>
          <p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>
        </p:sldLayout>
        """
    }

    private func slideLayoutRels() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="../slideMasters/slideMaster1.xml"/>
        </Relationships>
        """
    }

    // MARK: - Theme XML

    private func theme() -> String {
        let colors = themeColors
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Pitch Me Theme">
          <a:themeElements>
            <a:clrScheme name="PitchMe">
              <a:dk1><a:srgbClr val="\(colors.text)"/></a:dk1>
              <a:lt1><a:srgbClr val="\(colors.bg)"/></a:lt1>
              <a:dk2><a:srgbClr val="404040"/></a:dk2>
              <a:lt2><a:srgbClr val="F5F5F5"/></a:lt2>
              <a:accent1><a:srgbClr val="\(colors.accent)"/></a:accent1>
              <a:accent2><a:srgbClr val="4472C4"/></a:accent2>
              <a:accent3><a:srgbClr val="ED7D31"/></a:accent3>
              <a:accent4><a:srgbClr val="A9D18E"/></a:accent4>
              <a:accent5><a:srgbClr val="5B9BD5"/></a:accent5>
              <a:accent6><a:srgbClr val="70AD47"/></a:accent6>
              <a:hlink><a:srgbClr val="0563C1"/></a:hlink>
              <a:folHlink><a:srgbClr val="954F72"/></a:folHlink>
            </a:clrScheme>
            <a:fontScheme name="PitchMe">
              <a:majorFont><a:latin typeface="Helvetica Neue"/><a:ea typeface=""/><a:cs typeface=""/></a:majorFont>
              <a:minorFont><a:latin typeface="Helvetica Neue"/><a:ea typeface=""/><a:cs typeface=""/></a:minorFont>
            </a:fontScheme>
            <a:fmtScheme name="PitchMe">
              <a:fillStyleLst>
                <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
                <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
                <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
              </a:fillStyleLst>
              <a:lnStyleLst>
                <a:ln w="6350"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:ln>
                <a:ln w="12700"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:ln>
                <a:ln w="19050"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:ln>
              </a:lnStyleLst>
              <a:effectStyleLst>
                <a:effectStyle><a:effectLst/></a:effectStyle>
                <a:effectStyle><a:effectLst/></a:effectStyle>
                <a:effectStyle><a:effectLst/></a:effectStyle>
              </a:effectStyleLst>
              <a:bgFillStyleLst>
                <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
                <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
                <a:solidFill><a:schemeClr val="phClr"/></a:solidFill>
              </a:bgFillStyleLst>
            </a:fmtScheme>
          </a:themeElements>
        </a:theme>
        """
    }

    // MARK: - XML Escape

    private func xmlEscape(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&",  with: "&amp;")
            .replacingOccurrences(of: "<",  with: "&lt;")
            .replacingOccurrences(of: ">",  with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'",  with: "&apos;")
    }

    // MARK: - ZIP creation (pure Swift, no libz dependency)

    private func createZip(files: [String: Data]) throws -> Data {
        var zipData = Data()
        var centralDirectory: [(header: Data, offset: UInt32)] = []

        for (path, fileData) in files.sorted(by: { $0.key < $1.key }) {
            let offset = UInt32(zipData.count)
            let pathBytes = Array(path.utf8)
            let crc = crc32(fileData)

            // Local file header
            var localHeader = Data()
            localHeader.appendLE32(0x04034B50)    // signature
            localHeader.appendLE16(20)             // version needed
            localHeader.appendLE16(0)              // flags
            localHeader.appendLE16(0)              // compression (stored)
            localHeader.appendLE16(0)              // mod time
            localHeader.appendLE16(0)              // mod date
            localHeader.appendLE32(crc)            // CRC-32
            localHeader.appendLE32(UInt32(fileData.count)) // compressed size
            localHeader.appendLE32(UInt32(fileData.count)) // uncompressed size
            localHeader.appendLE16(UInt16(pathBytes.count)) // file name length
            localHeader.appendLE16(0)              // extra field length
            localHeader.append(contentsOf: pathBytes)

            // Central directory record
            var cdRecord = Data()
            cdRecord.appendLE32(0x02014B50)        // signature
            cdRecord.appendLE16(20)                // version made by
            cdRecord.appendLE16(20)                // version needed
            cdRecord.appendLE16(0)                 // flags
            cdRecord.appendLE16(0)                 // compression
            cdRecord.appendLE16(0)                 // mod time
            cdRecord.appendLE16(0)                 // mod date
            cdRecord.appendLE32(crc)               // CRC-32
            cdRecord.appendLE32(UInt32(fileData.count))
            cdRecord.appendLE32(UInt32(fileData.count))
            cdRecord.appendLE16(UInt16(pathBytes.count))
            cdRecord.appendLE16(0)                 // extra field length
            cdRecord.appendLE16(0)                 // file comment length
            cdRecord.appendLE16(0)                 // disk number start
            cdRecord.appendLE16(0)                 // internal attrs
            cdRecord.appendLE32(0)                 // external attrs
            cdRecord.appendLE32(offset)            // relative offset
            cdRecord.append(contentsOf: pathBytes)

            zipData.append(localHeader)
            zipData.append(fileData)
            centralDirectory.append((header: cdRecord, offset: offset))
        }

        // Write central directory
        let cdOffset = UInt32(zipData.count)
        var cdSize: UInt32 = 0
        for entry in centralDirectory {
            zipData.append(entry.header)
            cdSize += UInt32(entry.header.count)
        }

        // End of central directory
        var eocd = Data()
        eocd.appendLE32(0x06054B50)
        eocd.appendLE16(0)                         // disk number
        eocd.appendLE16(0)                         // disk with CD
        eocd.appendLE16(UInt16(centralDirectory.count))
        eocd.appendLE16(UInt16(centralDirectory.count))
        eocd.appendLE32(cdSize)
        eocd.appendLE32(cdOffset)
        eocd.appendLE16(0)                         // comment length
        zipData.append(eocd)

        return zipData
    }

    // MARK: - CRC-32

    private func crc32(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFFFFFF
        for byte in data {
            crc ^= UInt32(byte)
            for _ in 0..<8 {
                if crc & 1 != 0 {
                    crc = (crc >> 1) ^ 0xEDB88320
                } else {
                    crc >>= 1
                }
            }
        }
        return crc ^ 0xFFFFFFFF
    }
}

// MARK: - Data helpers

private extension Data {
    mutating func appendLE16(_ value: UInt16) {
        var v = value.littleEndian
        Swift.withUnsafeBytes(of: &v) { append(contentsOf: $0) }
    }
    mutating func appendLE32(_ value: UInt32) {
        var v = value.littleEndian
        Swift.withUnsafeBytes(of: &v) { append(contentsOf: $0) }
    }
}

private extension String {
    var utf8Data: Data { Data(utf8) }
}
