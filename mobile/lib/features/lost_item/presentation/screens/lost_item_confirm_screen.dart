import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LostItemConfirmScreen extends StatelessWidget {
  final Map<String, dynamic> formData;

  const LostItemConfirmScreen({
    super.key,
    required this.formData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '入力内容の確認',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildConfirmationSection('権利確認', [
            _buildConfirmationItem('権利放棄', formData['hasRightsWaiver'] == true ? '一切の権利を放棄' : '権利を保持する'),
            if (formData['hasRightsWaiver'] == false) ...[
              _buildConfirmationItem('保持する権利', (formData['rightsOptions'] as List<String>?)?.join(', ') ?? ''),
            ],
            _buildConfirmationItem('氏名等告知の同意', formData['hasConsentToDisclose'] == true ? '同意する' : '同意しない'),
          ]),
          _buildConfirmationSection('拾得者情報', [
            _buildConfirmationItem('お名前', formData['finderName'] ?? ''),
            _buildConfirmationItem('電話番号', formData['finderPhone'] ?? ''),
            _buildConfirmationItem('郵便番号', formData['postalCode'] ?? ''),
            _buildConfirmationItem('住所', formData['finderAddress'] ?? ''),
          ]),
          _buildConfirmationSection('拾得日時', [
            _buildConfirmationItem('拾得日', formData['foundDate']?.toString() ?? ''),
            _buildConfirmationItem('拾得時刻', formData['foundTime']?.toString() ?? ''),
          ]),
          _buildConfirmationSection('拾得場所', [
            _buildConfirmationItem('路線名', formData['routeName'] ?? ''),
            _buildConfirmationItem('車番', formData['vehicleNumber'] ?? ''),
            _buildConfirmationItem('その他', formData['otherLocation'] ?? ''),
          ]),
          _buildConfirmationSection('基本情報', [
            if (formData['hasCash'] == true) ...[
              _buildConfirmationItem('現金', '有り'),
              _buildConfirmationItem('10,000円札', formData['yen10000']?.toString() ?? '0'),
              _buildConfirmationItem('5,000円札', formData['yen5000']?.toString() ?? '0'),
              _buildConfirmationItem('2,000円札', formData['yen2000']?.toString() ?? '0'),
              _buildConfirmationItem('1,000円札', formData['yen1000']?.toString() ?? '0'),
              _buildConfirmationItem('500円玉', formData['yen500']?.toString() ?? '0'),
              _buildConfirmationItem('100円玉', formData['yen100']?.toString() ?? '0'),
              _buildConfirmationItem('50円玉', formData['yen50']?.toString() ?? '0'),
              _buildConfirmationItem('10円玉', formData['yen10']?.toString() ?? '0'),
              _buildConfirmationItem('5円玉', formData['yen5']?.toString() ?? '0'),
              _buildConfirmationItem('1円玉', formData['yen1']?.toString() ?? '0'),
            ],
            _buildConfirmationItem('物件の色', formData['itemColor'] ?? ''),
            _buildConfirmationItem('品種・形状、特徴・内容', formData['itemDescription'] ?? ''),
            _buildConfirmationItem('預り証発行', formData['needsReceipt'] == true ? '有り' : '無し'),
          ]),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                    side: BorderSide(color: Colors.blue[700]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '編集に戻る',
                    style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 登録処理の実装
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '登録する',
                    style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSection(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.notoSans(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.notoSans(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
