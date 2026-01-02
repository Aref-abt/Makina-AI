import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class ExportService {
  // Generate PDF Report
  static Future<void> generatePDFReport({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    required List<TicketModel>? tickets,
    required List<UserModel>? users,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 2)),
            ),
            padding: const pw.EdgeInsets.only(bottom: 10),
            margin: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Makina AI',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Predictive Maintenance Platform',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey,
                  ),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            padding: const pw.EdgeInsets.only(top: 10),
            decoration: pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(width: 1)),
            ),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Generated on ${DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey),
            ),
            pw.SizedBox(height: 20),

            // Summary Statistics
            if (tickets != null && tickets.isNotEmpty) ...[
              pw.Text('Summary',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Metric',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Value',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Total Tickets')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${tickets.length}')),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Resolved')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                            '${tickets.where((t) => t.status == TicketStatus.done).length}')),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('In Progress')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                            '${tickets.where((t) => t.status == TicketStatus.inProgress).length}')),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('To Do')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                            '${tickets.where((t) => t.status == TicketStatus.toDo).length}')),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Critical Issues')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                            '${tickets.where((t) => t.severity == SeverityLevel.high).length}')),
                  ]),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // Data Table
            if (headers.isNotEmpty && rows.isNotEmpty) ...[
              pw.Text('Details',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  for (int i = 0; i < headers.length; i++)
                    i: pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: headers
                        .map((h) => pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(h,
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                            ))
                        .toList(),
                  ),
                  ...rows.map((row) => pw.TableRow(
                        children: row
                            .map((cell) => pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(cell),
                                ))
                            .toList(),
                      )),
                ],
              ),
            ],
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          '${title.replaceAll(' ', '_')}_${DateFormat('yyyy_MM_dd_HHmm').format(DateTime.now())}.pdf',
    );
  }

  // Generate CSV Report
  static String generateCSV({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    StringBuffer csv = StringBuffer();

    // Title
    csv.writeln(title);
    csv.writeln(
        'Generated: ${DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now())}');
    csv.writeln('');

    // Headers
    csv.writeln(headers.join(','));

    // Rows
    for (final row in rows) {
      csv.writeln(row.map((cell) => '"$cell"').join(','));
    }

    return csv.toString();
  }

  // Export tickets to CSV
  static String exportTicketsToCSV(List<TicketModel> tickets) {
    List<String> headers = [
      'ID',
      'Title',
      'Machine',
      'Status',
      'Severity',
      'Created Date'
    ];
    List<List<String>> rows = tickets
        .map((ticket) => [
              ticket.id,
              ticket.title,
              ticket.machineName,
              ticket.status.displayName,
              ticket.severity.displayName,
              DateFormat('MMM dd, yyyy').format(ticket.createdAt),
            ])
        .toList();

    return generateCSV(title: 'Tickets Report', headers: headers, rows: rows);
  }

  // Export users to CSV
  static String exportUsersToCSV(List<UserModel> users) {
    List<String> headers = ['Name', 'Email', 'Role', 'Employee ID', 'Floor'];
    List<List<String>> rows = users
        .map((user) => [
              user.fullName,
              user.email,
              user.role.displayName,
              user.employeeId,
              user.assignedFloor ?? 'N/A',
            ])
        .toList();

    return generateCSV(title: 'Users Report', headers: headers, rows: rows);
  }
}
