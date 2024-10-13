import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:password_warden/models/password_record.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<bool> generateEncryptedPDF(
    List<PasswordRecord> storedInfo, String password) async {
  PdfDocument document = PdfDocument();

  PdfSecurity security = document.security;
  security.userPassword = password;
  // security.ownerPassword = 'owner_password'; // Owner password

  PdfPage page = document.pages.add();
  PdfGraphics graphics = page.graphics;

  PdfBrush headingBrush = PdfBrushes.blue;
  PdfFont headingFont =
      PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
  graphics.drawString(
    'Password Warden Stored Credentials',
    headingFont,
    brush: headingBrush,
    bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 50),
    format: PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    ),
  );

  PdfFont subTextFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
  graphics.drawString(
    'Please handle this report with care, as it contains all credentials stored in the Password Warden app.',
    subTextFont,
    bounds: Rect.fromLTWH(0, 60, page.getClientSize().width, 30),
    format: PdfStringFormat(
      alignment: PdfTextAlignment.center,
    ),
  );

  PdfGrid pdfGrid = PdfGrid();
  pdfGrid.columns.add(count: 4);

  PdfGridRow header = pdfGrid.headers.add(1)[0];
  header.cells[0].value = 'Application Name';
  header.cells[1].value = 'Username';
  header.cells[2].value = 'Password';
  header.cells[3].value = 'Additional Info';

  header.style = PdfGridCellStyle(
    backgroundBrush: PdfBrushes.darkBlue,
    textBrush: PdfBrushes.white,
    font:
        PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
  );

  for (var item in storedInfo) {
    PdfGridRow row = pdfGrid.rows.add();
    row.cells[0].value = item.applicationName;
    row.cells[1].value = item.username;
    row.cells[2].value = item.password;
    row.cells[3].value = item.additionalInfo.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(',\n');

    row.style = PdfGridCellStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
      cellPadding: PdfPaddings(left: 5, right: 5, top: 2, bottom: 2),
    );
  }

  pdfGrid.style = PdfGridStyle(
    cellPadding: PdfPaddings(left: 10, right: 10, top: 5, bottom: 5),
  );

  pdfGrid.draw(
    page: page,
    bounds: Rect.fromLTWH(
        0, 100, page.getClientSize().width, page.getClientSize().height),
  );

  PdfFont footerFont =
      PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
  graphics.drawString(
    'End of Report',
    footerFont,
    bounds: Rect.fromLTWH(
        0, page.getClientSize().height - 40, page.getClientSize().width, 30),
    format: PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    ),
  );

  List<int> bytes = document.saveSync();

  final directory = Directory('/storage/emulated/0/Download');
  final downloadsPath = directory.path;
  final path = '$downloadsPath/protected_table.pdf';
  final file = File(path);

  await file.writeAsBytes(bytes);

  document.dispose();

  return true;
}
