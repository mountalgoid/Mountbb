import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../models/node_model.dart';
import '../providers/mountmap_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/chart_engine.dart';
import '../screens/attachment_viewer_screen.dart';
import '../services/auth_service.dart';

class DescriptionTemplate {
  final String title;
  final String category;
  final IconData icon;
  final String description;
  final String recommendedChartType;
  final List<List<String>> data;

  const DescriptionTemplate({
    required this.title,
    required this.category,
    required this.icon,
    required this.description,
    required this.recommendedChartType,
    required this.data,
  });
}

final List<DescriptionTemplate> kDescriptionTemplates = [
  // MONEY MANAGEMENT
  const DescriptionTemplate(
    title: "Advanced Money & Cashflow",
    category: "MONEY MANAGEMENT",
    icon: Icons.account_balance_wallet_rounded,
    description: "Multi-category budget, actual vs target, variance & financial status.",
    recommendedChartType: "Histogram",
    data: [
      ['Category', 'Type', 'Target (IDR)', 'Actual (IDR)', 'Variance (IDR)', 'Status'],
      ['Pemasukan Utama', 'Income', '15000000', '15500000', '+500000', 'Surplus'],
      ['Investasi & Tabungan', 'Savings', '4000000', '4000000', '0', 'On Target'],
      ['Kebutuhan Rutin', 'Expense', '5000000', '4800000', '-200000', 'Efficient'],
      ['Cicilan & Tagihan', 'Expense', '3000000', '3000000', '0', 'Paid'],
      ['Hiburan & Gaya Hidup', 'Expense', '2000000', '2300000', '+300000', 'Overbudget'],
      ['Dana Darurat', 'Savings', '1000000', '1000000', '0', 'On Target'],
    ],
  ),
  const DescriptionTemplate(
    title: "Investment Portfolio & Asset Allocation",
    category: "MONEY MANAGEMENT",
    icon: Icons.pie_chart_outline_rounded,
    description: "Asset distribution, portfolio value, ROI percentage and risk profile.",
    recommendedChartType: "Multi-level Pie Chart",
    data: [
      ['Asset Class', 'Specific Asset', 'Capital (IDR)', 'Current Value (IDR)', 'ROI (%)', 'Risk'],
      ['Saham & Reksadana', 'IHSG Top 10', '25000000', '28500000', '14.0', 'High'],
      ['Crypto Asset', 'Bitcoin & ETH', '10000000', '13500000', '35.0', 'Very High'],
      ['Obligasi Negara', 'ORI / SBR', '20000000', '21200000', '6.0', 'Low'],
      ['Emas Digital', 'Antam Logam Mulia', '15000000', '16800000', '12.0', 'Low'],
      ['Cash & Deposito', 'Bank Deposito', '10000000', '10400000', '4.0', 'Safe'],
    ],
  ),
  const DescriptionTemplate(
    title: "Debt & Financial Goal Planner",
    category: "MONEY MANAGEMENT",
    icon: Icons.savings_rounded,
    description: "Target savings, monthly progress, remaining balance, and target deadline.",
    recommendedChartType: "Radial Bar Chart",
    data: [
      ['Goal / Debt Name', 'Target Amount', 'Current Saved', 'Remaining', 'Deadline', 'Status'],
      ['Dana Darurat (6 Bulan)', '60000000', '45000000', '15000000', '2025-12-31', '75% Done'],
      ['DP Rumah Pertama', '150000000', '60000000', '90000000', '2026-06-30', '40% Done'],
      ['Liburan Jepang', '25000000', '20000000', '5000000', '2025-08-15', '80% Done'],
      ['Upgrade Laptop Workstation', '20000000', '18000000', '2000000', '2025-04-30', '90% Done'],
    ],
  ),

  // CREDENTIAL & PASSWORD MANAGEMENT
  const DescriptionTemplate(
    title: "Secure Account & Password Vault",
    category: "CREDENTIALS & SECURITY",
    icon: Icons.lock_person_rounded,
    description: "Centralized account credentials with category, security rating, and 2FA info.",
    recommendedChartType: "Rose Chart",
    data: [
      ['Service / App', 'Username / Email', 'Password / Master Key', 'Category', 'Security Rating', '2FA Status'],
      ['Google Worksuite', 'admin@mountmap.io', '••••••••••••', 'Work', 'Strong (100%)', 'Enabled (TOTP)'],
      ['GitHub Enterprise', 'dev-lead@mountmap.io', '••••••••••••', 'Development', 'Very Strong (100%)', 'Security Key'],
      ['AWS Console', 'root-admin', '••••••••••••', 'Infrastructure', 'Critical (100%)', 'Hardware Token'],
      ['Bank Mandiri BKN', 'user_financial_88', '••••••••••••', 'Banking', 'High Security', 'SMS & Biometric'],
      ['Figma Pro', 'designer@mountmap.io', '••••••••••••', 'Design', 'Medium', 'Enabled'],
    ],
  ),
  const DescriptionTemplate(
    title: "API Keys & Token Management",
    category: "CREDENTIALS & SECURITY",
    icon: Icons.key_rounded,
    description: "Track API tokens, secret keys, environment, rate limits and expiration.",
    recommendedChartType: "Butterfly Chart",
    data: [
      ['Service / Provider', 'Key ID / Client', 'Environment', 'Rate Limit (req/m)', 'Expiry Date', 'Status'],
      ['OpenAI API', 'sk-proj-99882...', 'Production', '10000', '2025-12-31', 'Active'],
      ['Stripe Payment', 'pk_live_51M...', 'Production', '5000', '2026-01-01', 'Active'],
      ['Firebase Cloud', 'mountmap-prod-app', 'Production', '50000', '2027-05-15', 'Active'],
      ['SendGrid Email', 'SG.x892a10...', 'Staging', '2000', '2025-09-30', 'Expiring Soon'],
      ['Mapbox GL', 'pk.eyJ1Ijoib...', 'Development', '1000', '2025-11-01', 'Active'],
    ],
  ),
  const DescriptionTemplate(
    title: "Server & DB Connection Vault",
    category: "CREDENTIALS & SECURITY",
    icon: Icons.dns_rounded,
    description: "Server IP, SSH ports, database credentials, environment and access level.",
    recommendedChartType: "Sankey Diagram",
    data: [
      ['Host / Server Name', 'IP / Domain', 'Port / Service', 'Admin User', 'Auth Method', 'Env Level'],
      ['Production Primary DB', '10.0.1.50', '5432 (PostgreSQL)', 'postgres_admin', 'TLS Certificate', 'Production'],
      ['Redis Cache Cluster', '10.0.1.80', '6379 (Redis)', 'default', 'Auth Passkey', 'Production'],
      ['App Kubernetes Node', '100.64.0.12', '22 (SSH)', 'deploy_sys', 'ED25519 Key', 'Production'],
      ['Staging Sandbox', '192.168.1.100', '22 / 3306', 'dev_root', 'SSH Keypair', 'Staging'],
    ],
  ),

  // PROJECT & TASK TRACKER
  const DescriptionTemplate(
    title: "Agile Sprint & Task Board",
    category: "PROJECT & MANAGEMENT",
    icon: Icons.task_alt_rounded,
    description: "Sprint tasks, assignees, story points, priority levels and execution status.",
    recommendedChartType: "Pareto Chart",
    data: [
      ['Task Name', 'Assignee', 'Story Points', 'Priority', 'Status', 'DueDate'],
      ['Auth Refactoring', 'Alex Dev', '8', 'High', 'In Progress', '2025-03-20'],
      ['UI Chart Engine Upgrade', 'Jules', '13', 'Critical', 'Completed', '2025-03-18'],
      ['Backend Speed Optimization', 'Sarah', '5', 'Medium', 'Review', '2025-03-22'],
      ['PDF Export Bugfix', 'Budi', '3', 'Low', 'Backlog', '2025-03-25'],
      ['User Analytics Dashboard', 'Maya', '8', 'High', 'In Progress', '2025-03-24'],
    ],
  ),

  // HABIT & HEALTH TRACKER
  const DescriptionTemplate(
    title: "Weekly Fitness & Health Tracker",
    category: "HEALTH & LIFESTYLE",
    icon: Icons.directions_run_rounded,
    description: "Daily workout duration, calories burned, water intake, and sleep quality.",
    recommendedChartType: "Histogram",
    data: [
      ['Day', 'Workout (Mins)', 'Calories (kcal)', 'Water (Liters)', 'Sleep (Hours)', 'Overall Feel'],
      ['Monday', '45', '420', '2.5', '7.5', 'Great'],
      ['Tuesday', '60', '580', '3.0', '8.0', 'Energetic'],
      ['Wednesday', '30', '290', '2.0', '6.5', 'Tired'],
      ['Thursday', '50', '490', '2.8', '7.0', 'Good'],
      ['Friday', '40', '380', '2.5', '8.5', 'Rested'],
      ['Saturday', '90', '850', '3.5', '9.0', 'Peak'],
      ['Sunday', '20', '180', '2.0', '8.0', 'Relaxed'],
    ],
  ),

  // SALES & MARKETING
  const DescriptionTemplate(
    title: "Sales Funnel & Conversion Rates",
    category: "SALES & MARKETING",
    icon: Icons.filter_alt_rounded,
    description: "Funnel stages, lead volume, conversion rate %, and estimated value.",
    recommendedChartType: "Alluvial Diagram",
    data: [
      ['Funnel Stage', 'Lead Count', 'Conversion Rate (%)', 'Pipeline Value (USD)'],
      ['Website Visitors', '50000', '100.0', '0'],
      ['Leads / Signups', '7500', '15.0', '150000'],
      ['Qualified Leads', '3000', '40.0', '120000'],
      ['Demo Scheduled', '1200', '40.0', '96000'],
      ['Proposal Sent', '600', '50.0', '72000'],
      ['Closed Won', '250', '41.6', '50000'],
    ],
  ),
  const DescriptionTemplate(
    title: "Marketing Campaign ROI & Performance",
    category: "SALES & MARKETING",
    icon: Icons.campaign_rounded,
    description: "Campaign spend, impressions, CTR %, leads generated, and Net ROI.",
    recommendedChartType: "Butterfly Chart",
    data: [
      ['Channel / Campaign', 'Ad Spend (USD)', 'Impressions', 'CTR (%)', 'Leads', 'ROI (%)'],
      ['Google Search Ads', '5000', '250000', '4.2', '850', '180'],
      ['Meta Sponsored Post', '3500', '480000', '2.8', '620', '140'],
      ['LinkedIn B2B Ads', '4000', '95000', '1.9', '210', '220'],
      ['TikTok Video Campaign', '2000', '650000', '3.5', '410', '95'],
      ['Email Newsletter Pro', '800', '45000', '8.5', '390', '310'],
    ],
  ),

  // RISK & ARCHITECTURE
  const DescriptionTemplate(
    title: "Cyber Security & Risk Assessment Matrix",
    category: "RISK & COMPLIANCE",
    icon: Icons.security_rounded,
    description: "Risk items, threat likelihood, impact level, risk score, and mitigation plan.",
    recommendedChartType: "Contour Plot",
    data: [
      ['Risk Item', 'Likelihood (1-10)', 'Impact (1-10)', 'Risk Score', 'Owner', 'Mitigation Plan'],
      ['Data Breach / Leak', '4', '9', '36', 'SecOps', 'Implement zero-trust & AES256'],
      ['DDoS Attack Outage', '6', '7', '42', 'DevOps', 'Enable Cloudflare Enterprise Guard'],
      ['Unpatched Dependency', '7', '5', '35', 'AppDev', 'Automate Dependabot PR reviews'],
      ['Insider Credential Abuse', '3', '8', '24', 'IAM Team', 'Enforce Hardware YubiKeys & MFA'],
      ['Database Corruption', '2', '10', '20', 'DBA', 'Real-time multi-region replication'],
    ],
  ),
  const DescriptionTemplate(
    title: "Software System Health & Latency Metrics",
    category: "RISK & COMPLIANCE",
    icon: Icons.speed_rounded,
    description: "Microservices uptime %, latency p99 (ms), error rate %, and throughput.",
    recommendedChartType: "Taylor Diagram",
    data: [
      ['Service Name', 'Uptime (%)', 'p99 Latency (ms)', 'Error Rate (%)', 'RPS', 'Health'],
      ['Auth Gateway Service', '99.99', '45', '0.01', '3500', 'Healthy'],
      ['User Profile API', '99.95', '120', '0.04', '1800', 'Healthy'],
      ['Payment Processor', '99.99', '280', '0.02', '650', 'Optimal'],
      ['Search & Vector Engine', '99.85', '450', '0.15', '1200', 'Warning'],
      ['Notification Queue', '99.90', '85', '0.05', '2200', 'Healthy'],
    ],
  ),
];

class ProfessionalDescriptionPanel extends StatefulWidget {
  final NodeModel node;
  final VoidCallback onClose;

  const ProfessionalDescriptionPanel({
    super.key,
    required this.node,
    required this.onClose,
  });

  @override
  State<ProfessionalDescriptionPanel> createState() => _ProfessionalDescriptionPanelState();
}

class _ProfessionalDescriptionPanelState extends State<ProfessionalDescriptionPanel> {
  String? _editingBlockId;
  int _tableGeneration = 0;

  // Embedded chart interactive settings state per block
  final Map<String, Map<String, dynamic>> _chartInteractiveState = {};

  // Vault Biometric Lock state per block ID
  final Set<String> _lockedBlockIds = {};
  final Set<String> _unlockedBlockIds = {};

  bool _isBlockVaultLocked(String blockId) {
    if (_unlockedBlockIds.contains(blockId)) return false;
    return _lockedBlockIds.contains(blockId);
  }

  Future<void> _unlockBlockVault(String blockId) async {
    final authenticated = await AuthService.authenticate();
    if (authenticated) {
      setState(() {
        _unlockedBlockIds.add(blockId);
        _lockedBlockIds.remove(blockId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vault Unlocked Successfully"), backgroundColor: MountMapColors.teal),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biometric Authentication Failed"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Map<String, dynamic> _getChartState(String blockId) {
    return _chartInteractiveState.putIfAbsent(blockId, () => {
      'primaryColor': MountMapColors.teal,
      'secondaryColor': MountMapColors.violet,
      'showStats': true,
      'showTrend': false,
      'intensity': 0.65,
      'thickness': 22.0,
      'opacity': 0.75,
    });
  }

  void _addTextItem() {
    final provider = Provider.of<MountMapProvider>(context, listen: false);
    final blockId = DateTime.now().millisecondsSinceEpoch.toString();
    provider.addDescriptionBlock(widget.node.id, DescriptionBlock(
      id: blockId,
      type: BlockType.text,
      content: "",
    ));
    setState(() {
      _editingBlockId = blockId;
    });
  }

  Future<void> _addAttachmentItem() async {
    final provider = Provider.of<MountMapProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: provider.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Add Attachment", style: TextStyle(color: provider.textColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const CircleAvatar(backgroundColor: Colors.indigoAccent, child: Icon(Icons.link, color: Colors.white, size: 20)),
              title: Text("Add Web Link", style: TextStyle(color: provider.textColor)),
              onTap: () {
                Navigator.pop(context);
                _showAddLinkDialog(provider);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.upload_file, color: Colors.white, size: 20)),
              title: Text("Pick Local File", style: TextStyle(color: provider.textColor)),
              onTap: () {
                Navigator.pop(context);
                _pickAndAddFile(provider);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.add_box_rounded, color: Colors.white, size: 20)),
              title: Text("Create New File", style: TextStyle(color: provider.textColor)),
              onTap: () {
                Navigator.pop(context);
                _showCreateFileDialog(provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLinkDialog(MountMapProvider provider) {
    final urlCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: provider.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Add Web Link", style: TextStyle(color: provider.textColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: provider.textColor),
              decoration: InputDecoration(
                labelText: "Display Name (Optional)",
                labelStyle: TextStyle(color: provider.textColor.withValues(alpha: 0.5)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlCtrl,
              style: TextStyle(color: provider.textColor),
              decoration: InputDecoration(
                labelText: "URL (https://...)",
                labelStyle: TextStyle(color: provider.textColor.withValues(alpha: 0.5)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "https://google.com",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: MountMapColors.teal, foregroundColor: Colors.white),
            onPressed: () {
              if (urlCtrl.text.isNotEmpty) {
                String url = urlCtrl.text;
                if (!url.startsWith('http')) url = 'https://$url';
                String name = nameCtrl.text.isNotEmpty ? nameCtrl.text : url;

                provider.addDescriptionBlock(widget.node.id, DescriptionBlock(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: BlockType.attachment,
                  attachment: AttachmentItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    value: url,
                    type: 'link',
                  ),
                ));
                Navigator.pop(context);
              }
            },
            child: const Text("ADD LINK"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAddFile(MountMapProvider provider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null) {
        for (var file in result.files) {
          if (file.path != null) {
            String permanentPath = await provider.saveAttachmentFile(file.path!, file.name);
            provider.addDescriptionBlock(widget.node.id, DescriptionBlock(
              id: "${DateTime.now().millisecondsSinceEpoch}_${file.name}",
              type: BlockType.attachment,
              attachment: AttachmentItem(
                id: "${DateTime.now().millisecondsSinceEpoch}_${file.name}",
                name: file.name,
                value: permanentPath,
                type: 'file'
              ),
            ));
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to pick file")));
    }
  }

  void _showCreateFileDialog(MountMapProvider provider) {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: provider.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Create New File", style: TextStyle(color: provider.textColor, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameCtrl,
          style: TextStyle(color: provider.textColor),
          decoration: InputDecoration(
            labelText: "Filename with extension",
            labelStyle: TextStyle(color: provider.textColor.withValues(alpha: 0.5)),
            hintText: "note.txt",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: MountMapColors.teal, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                try {
                  final dir = await getApplicationDocumentsDirectory();
                  final fileDir = Directory('${dir.path}/MountAttachments');
                  if (!await fileDir.exists()) await fileDir.create();

                  final file = File('${fileDir.path}/${nameCtrl.text}');
                  if (!await file.exists()) {
                    await file.writeAsString("");
                  }

                  provider.addDescriptionBlock(widget.node.id, DescriptionBlock(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: BlockType.attachment,
                    attachment: AttachmentItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text,
                      value: file.path,
                      type: 'file'
                    ),
                  ));
                  if (!mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text("CREATE"),
          ),
        ],
      ),
    );
  }

  void _addTableItem() {
    final provider = Provider.of<MountMapProvider>(context, listen: false);
    _showTemplatePickerModal(
      context: context,
      provider: provider,
      title: "CREATE TABLE WITH TEMPLATE",
      onSelectTemplate: (template) {
        final blockId = DateTime.now().millisecondsSinceEpoch.toString();
        provider.addDescriptionBlock(widget.node.id, DescriptionBlock(
          id: blockId,
          type: BlockType.table,
          tableData: template.data.map((r) => List<String>.from(r)).toList(),
        ));
      },
      onSelectBlank: () {
        final blockId = DateTime.now().millisecondsSinceEpoch.toString();
        provider.addDescriptionBlock(widget.node.id, DescriptionBlock(
          id: blockId,
          type: BlockType.table,
          tableData: [
            ['Column 1', 'Column 2'],
            ['Data 1', 'Data 2'],
          ],
        ));
        _showTableEditor(provider, widget.node.id, blockId);
      },
    );
  }

  void _addChartItem() {
    final provider = Provider.of<MountMapProvider>(context, listen: false);
    _showTemplatePickerModal(
      context: context,
      provider: provider,
      title: "CREATE CHART WITH TEMPLATE",
      onSelectTemplate: (template) {
        final blockId = DateTime.now().millisecondsSinceEpoch.toString();
        provider.addDescriptionBlock(widget.node.id, DescriptionBlock(
          id: blockId,
          type: BlockType.chart,
          chartType: template.recommendedChartType,
          tableData: template.data.map((r) => List<String>.from(r)).toList(),
        ));
      },
      onSelectBlank: () {
        _showChartTypePicker(context, provider);
      },
    );
  }

  void _showTemplatePickerModal({
    required BuildContext context,
    required MountMapProvider provider,
    required String title,
    required Function(DescriptionTemplate) onSelectTemplate,
    required VoidCallback onSelectBlank,
  }) {
    final categories = <String, List<DescriptionTemplate>>{};
    for (var t in kDescriptionTemplates) {
      categories.putIfAbsent(t.category, () => []).add(t);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.82,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: provider.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: provider.textColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: MountMapColors.teal,
                            letterSpacing: 2,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Pilih template siap pakai untuk Money Management, Credential Vault, dsb.",
                          style: TextStyle(
                            color: provider.textColor.withValues(alpha: 0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onSelectBlank();
                    },
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text("Blank", style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: provider.textColor,
                      side: BorderSide(color: provider.textColor.withValues(alpha: 0.2)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: categories.entries.map((catEntry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(width: 4, height: 14, decoration: BoxDecoration(color: MountMapColors.teal, borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 8),
                            Text(
                              catEntry.key,
                              style: TextStyle(color: provider.textColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                            ),
                          ],
                        ),
                      ),
                      ...catEntry.value.map((template) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: provider.textColor.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: provider.textColor.withValues(alpha: 0.06)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: MountMapColors.teal.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(template.icon, color: MountMapColors.teal, size: 20),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    template.title,
                                    style: TextStyle(color: provider.textColor, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: MountMapColors.violet.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    template.recommendedChartType,
                                    style: const TextStyle(color: MountMapColors.violet, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                template.description,
                                style: TextStyle(color: provider.textColor.withValues(alpha: 0.5), fontSize: 10),
                              ),
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MountMapColors.teal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                onSelectTemplate(template);
                              },
                              child: const Text("GUNAKAN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChartTypePicker(BuildContext context, MountMapProvider provider) {
    final Map<String, List<Map<String, dynamic>>> categories = {
      "FLOW & RELATIONAL": [
        {"name": "Alluvial Diagram", "icon": Icons.waterfall_chart_rounded},
        {"name": "Sankey Diagram", "icon": Icons.subway_rounded},
        {"name": "Chord Diagram", "icon": Icons.donut_large_rounded},
        {"name": "Hyperbolic Tree", "icon": Icons.account_tree_rounded},
      ],
      "COMPARISON & STATS": [
        {"name": "Butterfly Chart", "icon": Icons.compare_arrows_rounded},
        {"name": "Histogram", "icon": Icons.bar_chart_rounded},
        {"name": "Pareto Chart", "icon": Icons.show_chart_rounded},
        {"name": "Radial Bar Chart", "icon": Icons.vignette_rounded},
        {"name": "Rose Chart", "icon": Icons.filter_tilt_shift_rounded},
      ],
      "HIERARCHICAL": [
        {"name": "Treemap", "icon": Icons.grid_view_rounded},
        {"name": "Multi-level Pie Chart", "icon": Icons.pie_chart_rounded},
      ],
      "SCIENTIFIC & DATA": [
        {"name": "Contour Plot", "icon": Icons.waves_rounded},
        {"name": "Taylor Diagram", "icon": Icons.radar_rounded},
        {"name": "Three-dimensional Stream Graph", "icon": Icons.multiline_chart_rounded},
        {"name": "Data Table", "icon": Icons.table_view_rounded},
      ],
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: provider.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("SELECT CHART TYPE",
                    style: TextStyle(color: provider.textColor.withValues(alpha: 0.5), letterSpacing: 3, fontSize: 10, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: provider.textColor.withValues(alpha: 0.5)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: categories.entries.map((category) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                        child: Row(
                          children: [
                            Container(width: 4, height: 14, decoration: BoxDecoration(color: MountMapColors.teal, borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 10),
                            Text(category.key, style: TextStyle(color: provider.textColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                          ],
                        ),
                      ),
                      GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: category.value.length,
                        itemBuilder: (context, index) {
                          final chart = category.value[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _createChartBlock(provider, chart['name']);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: provider.textColor.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: provider.textColor.withValues(alpha: 0.05)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: MountMapColors.teal.withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(chart['icon'] as IconData, color: MountMapColors.teal, size: 24),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    chart['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: provider.textColor.withValues(alpha: 0.8), fontSize: 9, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createChartBlock(MountMapProvider provider, String chartType) {
    final blockId = DateTime.now().millisecondsSinceEpoch.toString();

    List<List<String>> initialData = [
      ['Label', 'Value'],
      ['A', '30'],
      ['B', '70'],
    ];

    if (chartType == "Sankey Diagram" || chartType == "Alluvial Diagram" || chartType == "Chord Diagram") {
      initialData = [
        ['Source', 'Target', 'Value'],
        ['A', 'B', '50'],
        ['B', 'C', '30'],
      ];
    } else if (chartType == "Treemap" || chartType == "Multi-level Pie Chart") {
      initialData = [
        ['Parent', 'Child', 'Value'],
        ['Total', 'Category A', '60'],
        ['Total', 'Category B', '40'],
      ];
    } else if (chartType == "Contour Plot") {
      initialData = [
        ['X', 'Y', 'Z'],
        ['10', '20', '35'],
        ['50', '40', '80'],
      ];
    }

    provider.addDescriptionBlock(widget.node.id, DescriptionBlock(
      id: blockId,
      type: BlockType.chart,
      chartType: chartType,
      tableData: initialData,
    ));

    _showTableEditor(provider, widget.node.id, blockId, isChart: true);
  }

  bool _isTableAttachmentValue(String value) {
    return value.startsWith(DescriptionBlock.tableFilePrefix) || value.startsWith(DescriptionBlock.tableLinkPrefix);
  }

  String _buildTableFileValue(String name, String path) => '${DescriptionBlock.tableFilePrefix}$name|$path';
  String _buildTableLinkValue(String name, String url) => '${DescriptionBlock.tableLinkPrefix}$name|$url';

  ({String name, String value}) _parseTableAttachmentValue(String raw) {
    final payload = raw.replaceFirst(DescriptionBlock.tableFilePrefix, '').replaceFirst(DescriptionBlock.tableLinkPrefix, '');
    final splitIndex = payload.indexOf('|');
    if (splitIndex == -1) {
      return (name: payload, value: payload);
    }
    return (
      name: payload.substring(0, splitIndex),
      value: payload.substring(splitIndex + 1),
    );
  }

  Widget _renderSmartTableCell(
    String value, {
    required Color textColor,
    bool isHeader = false,
    VoidCallback? onTap,
    Function(String)? onToggleCheckbox,
  }) {
    if (_isTableAttachmentValue(value)) {
      final parsed = _parseTableAttachmentValue(value);
      final isLink = value.startsWith(DescriptionBlock.tableLinkPrefix);
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: MountMapColors.teal.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: MountMapColors.teal.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isLink ? Icons.link_rounded : Icons.insert_drive_file_rounded, size: 13, color: MountMapColors.teal),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  parsed.name,
                  style: const TextStyle(color: MountMapColors.teal, fontSize: 11, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.open_in_new_rounded, size: 11, color: MountMapColors.teal),
            ],
          ),
        ),
      );
    }

    final trimmed = value.trim();
    final lower = trimmed.toLowerCase();

    // Checkbox Cell Type
    if (lower == '[x]' || lower == '✓' || lower == 'true' || lower == 'done') {
      return InkWell(
        onTap: () => onToggleCheckbox?.call('[ ]'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_box_rounded, color: Colors.greenAccent, size: 18),
            const SizedBox(width: 4),
            Text(trimmed, style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    if (lower == '[ ]' || lower == '☐' || lower == 'false' || lower == 'todo') {
      return InkWell(
        onTap: () => onToggleCheckbox?.call('[x]'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_box_outline_blank_rounded, color: textColor.withValues(alpha: 0.4), size: 18),
            const SizedBox(width: 4),
            Text(trimmed, style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 11)),
          ],
        ),
      );
    }

    // Rating Star Renderer
    if (trimmed.contains('★') || RegExp(r'^\d/5$').hasMatch(trimmed) || RegExp(r'^\d stars$').hasMatch(lower)) {
      int rating = 5;
      final match = RegExp(r'^(\d)').firstMatch(trimmed);
      if (match != null) {
        rating = int.tryParse(match.group(1)!) ?? 5;
      } else {
        rating = '★'.allMatches(trimmed).length;
      }
      rating = rating.clamp(1, 5);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (starIdx) => Icon(
            starIdx < rating ? Icons.star_rounded : Icons.star_border_rounded,
            size: 14,
            color: Colors.amberAccent,
          )),
          const SizedBox(width: 4),
          Text('$rating/5', style: const TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      );
    }

    // Status Badge Pill Renderer & Conditional Formatting Colors
    Color? badgeBg;
    Color? badgeText;

    if (['completed', 'done', 'surplus', 'active', 'optimal', 'healthy', 'paid', '100%', 'high security', 'efficient'].contains(lower) || lower.contains('done')) {
      badgeBg = Colors.greenAccent.withValues(alpha: 0.15);
      badgeText = Colors.greenAccent;
    } else if (['in progress', 'review', 'medium', 'expiring soon', 'warning', '75%'].contains(lower)) {
      badgeBg = Colors.cyanAccent.withValues(alpha: 0.15);
      badgeText = Colors.cyanAccent;
    } else if (['overbudget', 'critical', 'high', 'very high', 'risk', 'tired'].contains(lower) || lower.startsWith('-')) {
      badgeBg = Colors.redAccent.withValues(alpha: 0.15);
      badgeText = Colors.redAccent;
    } else if (['backlog', 'low', 'safe', 'on target', 'rested'].contains(lower) || lower.startsWith('+')) {
      badgeBg = MountMapColors.teal.withValues(alpha: 0.15);
      badgeText = MountMapColors.teal;
    }

    if (badgeBg != null && badgeText != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: badgeText.withValues(alpha: 0.3)),
        ),
        child: Text(
          trimmed,
          style: TextStyle(color: badgeText, fontSize: 11, fontWeight: FontWeight.w800),
        ),
      );
    }

    // Currency Formatting for pure numbers
    final numVal = double.tryParse(trimmed);
    String formattedText = trimmed;
    if (numVal != null && numVal.abs() >= 1000 && !trimmed.contains('.')) {
      formattedText = trimmed.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '.');
    }

    return Text(
      formattedText.isEmpty ? '-' : formattedText,
      style: TextStyle(
        color: isHeader ? textColor : (formattedText.isEmpty ? textColor.withValues(alpha: 0.3) : textColor),
        fontSize: isHeader ? 12 : 12,
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  String _displayTableCellValue(String value) {
    if (!_isTableAttachmentValue(value)) return value;
    final parsed = _parseTableAttachmentValue(value);
    final isLink = value.startsWith(DescriptionBlock.tableLinkPrefix);
    return isLink ? '[LINK] ${parsed.name}' : '[FILE] ${parsed.name}';
  }

  Future<void> _pickFileForTableCell(
    MountMapProvider provider,
    List<List<String>> data,
    int row,
    int column,
    void Function(void Function()) setModalState,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (result == null || result.files.isEmpty || result.files.first.path == null) return;
      final file = result.files.first;
      final savedPath = await provider.saveAttachmentFile(file.path!, file.name);
      setModalState(() {
        data[row][column] = _buildTableFileValue(file.name, savedPath);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to attach file to table cell')),
      );
    }
  }

    void _showFindAndReplaceDialog({
    required BuildContext context,
    required MountMapProvider provider,
    required List<List<String>> data,
    required VoidCallback onApplied,
  }) {
    final findCtrl = TextEditingController();
    final replaceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: provider.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.find_replace_rounded, color: MountMapColors.teal),
            const SizedBox(width: 8),
            Text('Find & Replace in Table', style: TextStyle(color: provider.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: findCtrl,
              style: TextStyle(color: provider.textColor),
              decoration: InputDecoration(
                labelText: 'Find Text / Pattern',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: replaceCtrl,
              style: TextStyle(color: provider.textColor),
              decoration: InputDecoration(
                labelText: 'Replace With',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: MountMapColors.teal, foregroundColor: Colors.white),
            onPressed: () {
              final query = findCtrl.text;
              final replacement = replaceCtrl.text;
              if (query.isNotEmpty) {
                int replaceCount = 0;
                for (int r = 0; r < data.length; r++) {
                  for (int c = 0; c < data[r].length; c++) {
                    if (data[r][c].contains(query)) {
                      data[r][c] = data[r][c].replaceAll(query, replacement);
                      replaceCount++;
                    }
                  }
                }
                Navigator.pop(context);
                onApplied();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Replaced $replaceCount occurrence(s)'), backgroundColor: MountMapColors.teal),
                );
              }
            },
            child: const Text('REPLACE ALL'),
          ),
        ],
      ),
    );
  }

  void _showAutoFillDialog({
    required BuildContext context,
    required MountMapProvider provider,
    required List<List<String>> data,
    required Set<String> selectedCells,
    required int? activeColumn,
    required int? activeRow,
    required String selectedMode,
    required VoidCallback onApplied,
  }) {
    String seriesType = 'Numbers'; // 'Numbers', 'Dates', 'Alphabet', 'Preset Labels'
    String targetRange = selectedMode == 'Column' && activeColumn != null
        ? 'Col ${activeColumn + 1}'
        : (selectedMode == 'Row' && activeRow != null ? 'Row ${activeRow + 1}' : 'Selected Cells (${selectedCells.length})');

    double startNum = 1.0;
    double stepNum = 1.0;
    DateTime startDate = DateTime.now();
    String dateStep = 'Daily'; // 'Daily', 'Weekly', 'Monthly', 'Yearly'
    String presetType = 'Days of Week'; // 'Days of Week', 'Months', 'Quarter', 'Status'

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: provider.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.auto_fix_high_rounded, color: MountMapColors.violet),
              const SizedBox(width: 8),
              Text("Auto-Fill & Series Generator", style: TextStyle(color: provider.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Target Range: $targetRange", style: const TextStyle(color: MountMapColors.teal, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: seriesType,
                  dropdownColor: provider.cardColor,
                  style: TextStyle(color: provider.textColor, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: "Series Type",
                    labelStyle: TextStyle(color: provider.textColor.withValues(alpha: 0.6)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['Numbers', 'Dates / Calendar', 'Alphabet', 'Preset Labels']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => seriesType = val);
                  },
                ),
                const SizedBox(height: 12),
                if (seriesType == 'Numbers') ...[
                  TextField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: provider.textColor),
                    decoration: InputDecoration(
                      labelText: "Start Number",
                      hintText: "1",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (v) => startNum = double.tryParse(v) ?? 1.0,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: provider.textColor),
                    decoration: InputDecoration(
                      labelText: "Step Increment",
                      hintText: "1",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (v) => stepNum = double.tryParse(v) ?? 1.0,
                  ),
                ] else if (seriesType == 'Dates / Calendar') ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text("Start: ${startDate.toString().split(' ')[0]}", style: TextStyle(color: provider.textColor, fontSize: 12)),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_month_rounded, size: 16),
                        label: const Text("Pick Date"),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setDialogState(() => startDate = picked);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: dateStep,
                    dropdownColor: provider.cardColor,
                    style: TextStyle(color: provider.textColor, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: "Interval",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => dateStep = val);
                    },
                  ),
                ] else if (seriesType == 'Preset Labels') ...[
                  DropdownButtonFormField<String>(
                    value: presetType,
                    dropdownColor: provider.cardColor,
                    style: TextStyle(color: provider.textColor, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: "Preset Category",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['Days of Week', 'Months', 'Quarter (Q1..Q4)', 'Task Status']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => presetType = val);
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: MountMapColors.violet, foregroundColor: Colors.white),
              onPressed: () {
                // Generate values
                final values = <String>[];
                int totalNeeded = 50; // max sequence length

                for (int i = 0; i < totalNeeded; i++) {
                  if (seriesType == 'Numbers') {
                    final val = startNum + (i * stepNum);
                    values.add(val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1));
                  } else if (seriesType == 'Dates / Calendar') {
                    DateTime dt = startDate;
                    if (dateStep == 'Daily') dt = startDate.add(Duration(days: i));
                    if (dateStep == 'Weekly') dt = startDate.add(Duration(days: i * 7));
                    if (dateStep == 'Monthly') dt = DateTime(startDate.year, startDate.month + i, startDate.day);
                    if (dateStep == 'Yearly') dt = DateTime(startDate.year + i, startDate.month, startDate.day);
                    values.add("${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}");
                  } else if (seriesType == 'Alphabet') {
                    values.add(String.fromCharCode(65 + (i % 26)));
                  } else if (seriesType == 'Preset Labels') {
                    if (presetType == 'Days of Week') {
                      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                      values.add(days[i % days.length]);
                    } else if (presetType == 'Months') {
                      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                      values.add(months[i % months.length]);
                    } else if (presetType == 'Quarter (Q1..Q4)') {
                      values.add("Q${(i % 4) + 1}");
                    } else {
                      final st = ['Backlog', 'In Progress', 'In Review', 'Completed'];
                      values.add(st[i % st.length]);
                    }
                  }
                }

                // Apply values based on selectedMode/target
                int valIdx = 0;
                if (selectedMode == 'Column' && activeColumn != null) {
                  for (int r = 1; r < data.length; r++) {
                    if (activeColumn < data[r].length) {
                      data[r][activeColumn] = values[valIdx % values.length];
                      valIdx++;
                    }
                  }
                } else if (selectedMode == 'Row' && activeRow != null && activeRow < data.length) {
                  for (int c = 0; c < data[activeRow].length; c++) {
                    data[activeRow][c] = values[valIdx % values.length];
                    valIdx++;
                  }
                } else if (selectedCells.isNotEmpty) {
                  final sortedKeys = selectedCells.toList()..sort();
                  for (var key in sortedKeys) {
                    final parts = key.split('_');
                    if (parts.length == 2) {
                      final r = int.tryParse(parts[0]);
                      final c = int.tryParse(parts[1]);
                      if (r != null && c != null && r < data.length && c < data[r].length) {
                        data[r][c] = values[valIdx % values.length];
                        valIdx++;
                      }
                    }
                  }
                }

                Navigator.pop(context);
                onApplied();
              },
              child: const Text("GENERATE & APPLY"),
            ),
          ],
        ),
      ),
    );
  }

  void _evaluateExcelFormulas(List<List<String>> data) {
    if (data.length < 2) return;

    for (int r = 1; r < data.length; r++) {
      for (int c = 0; c < data[r].length; c++) {
        final val = data[r][c].trim();
        if (val.startsWith('=')) {
          final upper = val.toUpperCase();

          // Range Formula: =SUM(A1:B5) or =AVG(A1:A5)
          final rangeMatch = RegExp(r'^=([A-Z]+)\(([A-Z]+\d+):([A-Z]+\d+)\)$').firstMatch(upper);
          if (rangeMatch != null) {
            final func = rangeMatch.group(1);
            final startCoord = _parseCellCoordinate(rangeMatch.group(2)!);
            final endCoord = _parseCellCoordinate(rangeMatch.group(3)!);

            if (startCoord != null && endCoord != null) {
              final nums = _extractRangeNumbers(data, startCoord, endCoord);
              if (func == 'SUM') {
                final res = nums.fold(0.0, (a, b) => a + b);
                data[r][c] = res % 1 == 0 ? res.toInt().toString() : res.toStringAsFixed(2);
              } else if (func == 'AVG' || func == 'AVERAGE') {
                final res = nums.isNotEmpty ? nums.fold(0.0, (a, b) => a + b) / nums.length : 0.0;
                data[r][c] = res % 1 == 0 ? res.toInt().toString() : res.toStringAsFixed(2);
              } else if (func == 'MIN') {
                final res = nums.isNotEmpty ? nums.reduce((a, b) => a < b ? a : b) : 0.0;
                data[r][c] = res % 1 == 0 ? res.toInt().toString() : res.toStringAsFixed(2);
              } else if (func == 'MAX') {
                final res = nums.isNotEmpty ? nums.reduce((a, b) => a > b ? a : b) : 0.0;
                data[r][c] = res % 1 == 0 ? res.toInt().toString() : res.toStringAsFixed(2);
              } else if (func == 'COUNT') {
                data[r][c] = nums.length.toString();
              }
              continue;
            }
          }

          // Simple Arithmetic: =A1+B1, =A1*B1, =A1-B1, =A1/B1
          final mathMatch = RegExp(r'^=([A-Z]+\d+)([\+\-\*\/])([A-Z]+\d+)$').firstMatch(upper);
          if (mathMatch != null) {
            final c1 = _parseCellCoordinate(mathMatch.group(1)!);
            final op = mathMatch.group(2)!;
            final c2 = _parseCellCoordinate(mathMatch.group(3)!);

            if (c1 != null && c2 != null) {
              final v1 = _getCellValueAsDouble(data, c1);
              final v2 = _getCellValueAsDouble(data, c2);
              double res = 0.0;
              if (op == '+') res = v1 + v2;
              if (op == '-') res = v1 - v2;
              if (op == '*') res = v1 * v2;
              if (op == '/') res = v2 != 0 ? v1 / v2 : 0.0;

              data[r][c] = res % 1 == 0 ? res.toInt().toString() : res.toStringAsFixed(2);
              continue;
            }
          }

          // Default column-based fallback
          if (upper.startsWith('=SUM(')) {
            final nums = _extractColumnNumbers(data, c, r);
            final sum = nums.fold(0.0, (a, b) => a + b);
            data[r][c] = sum % 1 == 0 ? sum.toInt().toString() : sum.toStringAsFixed(2);
          } else if (upper.startsWith('=AVG(') || upper.startsWith('=AVERAGE(')) {
            final nums = _extractColumnNumbers(data, c, r);
            final avg = nums.isNotEmpty ? nums.fold(0.0, (a, b) => a + b) / nums.length : 0.0;
            data[r][c] = avg % 1 == 0 ? avg.toInt().toString() : avg.toStringAsFixed(2);
          } else if (upper.startsWith('=MIN(')) {
            final nums = _extractColumnNumbers(data, c, r);
            final min = nums.isNotEmpty ? nums.reduce((a, b) => a < b ? a : b) : 0.0;
            data[r][c] = min % 1 == 0 ? min.toInt().toString() : min.toStringAsFixed(2);
          } else if (upper.startsWith('=MAX(')) {
            final nums = _extractColumnNumbers(data, c, r);
            final max = nums.isNotEmpty ? nums.reduce((a, b) => a > b ? a : b) : 0.0;
            data[r][c] = max % 1 == 0 ? max.toInt().toString() : max.toStringAsFixed(2);
          } else if (upper.startsWith('=COUNT(')) {
            final nums = _extractColumnNumbers(data, c, r);
            data[r][c] = nums.length.toString();
          }
        }
      }
    }
  }

  ({int row, int col})? _parseCellCoordinate(String coord) {
    final match = RegExp(r'^([A-Z]+)(\d+)$').firstMatch(coord.toUpperCase());
    if (match == null) return null;
    final colStr = match.group(1)!;
    final rowStr = match.group(2)!;

    int col = 0;
    for (int i = 0; i < colStr.length; i++) {
      col = col * 26 + (colStr.codeUnitAt(i) - 65);
    }
    int row = int.tryParse(rowStr) ?? 1;
    return (row: row, col: col);
  }

  double? _parseFlexibleNumber(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var v = raw.trim();
    if (v.startsWith('MM_FILE|') || v.startsWith('MM_LINK|') || v.contains('•')) return null;

    var cleaned = v.replaceAll(RegExp(r'[^\d\.,+\-]'), '').trim();
    if (cleaned.isEmpty) return null;
    final match = RegExp(r'^([+-]?)([\d\.,]+)$').firstMatch(cleaned);
    if (match == null) return null;

    final sign = match.group(1) ?? '';
    var numStr = match.group(2) ?? '';

    if (numStr.split('.').length - 1 > 1) {
      numStr = numStr.replaceAll('.', '');
    } else if (numStr.contains('.') && numStr.contains(',')) {
      numStr = numStr.replaceAll('.', '').replaceAll(',', '.');
    } else if (numStr.contains(',') && !numStr.contains('.')) {
      final parts = numStr.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        numStr = numStr.replaceAll(',', '.');
      } else {
        numStr = numStr.replaceAll(',', '');
      }
    } else if (numStr.contains('.')) {
      final parts = numStr.split('.');
      if (parts.length == 2 && parts[1].length == 3 && parts[0].length <= 3) {
        numStr = numStr.replaceAll('.', '');
      }
    }

    return double.tryParse(sign + numStr);
  }

  double _getCellValueAsDouble(List<List<String>> data, ({int row, int col}) c) {
    if (c.row < data.length && c.col < data[c.row].length) {
      return _parseFlexibleNumber(data[c.row][c.col]) ?? 0.0;
    }
    return 0.0;
  }

  List<double> _extractRangeNumbers(List<List<String>> data, ({int row, int col}) start, ({int row, int col}) end) {
    final nums = <double>[];
    int minR = math.min(start.row, end.row);
    int maxR = math.max(start.row, end.row);
    int minC = math.min(start.col, end.col);
    int maxC = math.max(start.col, end.col);

    for (int r = minR; r <= maxR; r++) {
      if (r >= data.length) continue;
      for (int c = minC; c <= maxC; c++) {
        if (c < data[r].length) {
          final d = _parseFlexibleNumber(data[r][c]);
          if (d != null) nums.add(d);
        }
      }
    }
    return nums;
  }

  List<double> _extractColumnNumbers(List<List<String>> data, int colIndex, int untilRow) {
    final nums = <double>[];
    for (int r = 1; r < untilRow; r++) {
      if (colIndex < data[r].length) {
        final d = _parseFlexibleNumber(data[r][colIndex]);
        if (d != null) nums.add(d);
      }
    }
    return nums;
  }

  void _showAddLinkForTableCell(
    MountMapProvider provider,
    List<List<String>> data,
    int row,
    int column,
    void Function(void Function()) setModalState,
  ) {
    final urlCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: provider.cardColor,
        title: Text('Attach Link to Cell', style: TextStyle(color: provider.textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: provider.textColor),
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: urlCtrl,
              style: TextStyle(color: provider.textColor),
              decoration: const InputDecoration(labelText: 'URL'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (urlCtrl.text.trim().isEmpty) return;
              var url = urlCtrl.text.trim();
              if (!url.startsWith('http')) url = 'https://$url';
              final name = nameCtrl.text.trim().isEmpty ? url : nameCtrl.text.trim();
              setModalState(() {
                data[row][column] = _buildTableLinkValue(name, url);
              });
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  Future<void> _openTableCellValue(String value) async {
    if (!_isTableAttachmentValue(value)) return;
    final parsed = _parseTableAttachmentValue(value);
    final isLink = value.startsWith(DescriptionBlock.tableLinkPrefix);

    try {
      if (isLink) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttachmentViewerScreen(
              item: AttachmentItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: parsed.name,
                value: parsed.value,
                type: 'link',
              ),
            ),
          ),
        );
      } else {
        final path = parsed.value.toLowerCase();
        final supportedExt = [
          '.jpg', '.jpeg', '.png', '.webp',
          '.txt',
          '.mp3', '.wav', '.m4a',
          '.mp4', '.mp5', '.mov', '.mkv'
        ];
        final isInAppSupported = supportedExt.any((ext) => path.endsWith(ext));

        if (isInAppSupported) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttachmentViewerScreen(
                item: AttachmentItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: parsed.name,
                  value: parsed.value,
                  type: 'file',
                ),
              ),
            ),
          );
        } else {
          await _openFileExternally(parsed.value);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot open table attachment: $e')),
      );
    }
  }

  Future<void> _exportTableToCSV(List<List<String>> data) async {
    try {
      final buffer = StringBuffer();
      for (var row in data) {
        final line = row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(',');
        buffer.writeln(line);
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Table_Export_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buffer.toString());
      await Share.shareXFiles([XFile(file.path)], text: 'Export Table CSV');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export CSV: $e')));
    }
  }

  Future<List<List<String>>?> _importTableFromCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result == null || result.files.isEmpty || result.files.first.path == null) return null;
      final file = File(result.files.first.path!);
      final content = await file.readAsString();
      final lines = content.split('\n');
      final newTable = <List<String>>[];

      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        if (line.contains('\t')) {
          newTable.add(line.split('\t').map((e) => e.trim().replaceAll('"', '')).toList());
        } else {
          newTable.add(line.split(',').map((e) => e.trim().replaceAll('"', '')).toList());
        }
      }
      return newTable.isNotEmpty ? newTable : null;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to import CSV: $e')));
      return null;
    }
  }

  void _showTableEditor(MountMapProvider provider, String nodeId, String blockId, {bool isChart = false}) {
    final node = provider.nodes.firstWhere((n) => n.id == nodeId);
    final block = node.descriptionBlocks.firstWhere((b) => b.id == blockId);
    List<List<String>> data = List.from(block.tableData?.map((row) => List<String>.from(row)) ?? [["", ""]]);
    if (data.isEmpty) {
      data = [["", ""]];
    }
    if (data.first.isEmpty) {
      data[0] = [""];
    }

    // Smart Calculator Selection Set & Mode & Editing state
    final Set<String> selectedCells = {};
    String? editingCellKey;
    String selectedMode = 'Selection'; // 'Selection', 'Column', 'Row', 'All'
    int? activeColumn;
    int? activeRow;
    String filterQuery = "";

    showModalBottomSheet(
      context: context,
      backgroundColor: provider.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Helper to extract numbers from selection / mode
          List<double> getSelectedNumbers() {
            final nums = <double>[];
            if (selectedMode == 'All') {
              for (int r = 1; r < data.length; r++) {
                for (int c = 0; c < data[r].length; c++) {
                  final v = _parseFlexibleNumber(data[r][c]);
                  if (v != null) nums.add(v);
                }
              }
            } else if (selectedMode == 'Column' && activeColumn != null) {
              for (int r = 1; r < data.length; r++) {
                if (activeColumn! < data[r].length) {
                  final v = _parseFlexibleNumber(data[r][activeColumn!]);
                  if (v != null) nums.add(v);
                }
              }
            } else if (selectedMode == 'Row' && activeRow != null && activeRow! < data.length) {
              for (int c = 0; c < data[activeRow!].length; c++) {
                final v = _parseFlexibleNumber(data[activeRow!][c]);
                if (v != null) nums.add(v);
              }
            } else {
              for (var key in selectedCells) {
                final parts = key.split('_');
                if (parts.length == 2) {
                  final r = int.tryParse(parts[0]);
                  final c = int.tryParse(parts[1]);
                  if (r != null && c != null && r < data.length && c < data[r].length) {
                    final v = _parseFlexibleNumber(data[r][c]);
                    if (v != null) nums.add(v);
                  }
                }
              }
            }
            return nums;
          }

          final nums = getSelectedNumbers();
          final calcSum = nums.isNotEmpty ? nums.reduce((a, b) => a + b) : 0.0;
          final calcAvg = nums.isNotEmpty ? calcSum / nums.length : 0.0;
          final calcMin = nums.isNotEmpty ? nums.reduce((a, b) => a < b ? a : b) : 0.0;
          final calcMax = nums.isNotEmpty ? nums.reduce((a, b) => a > b ? a : b) : 0.0;
          final calcCount = nums.length;

          // Compute Median & StdDev
          double calcMed = 0.0;
          double calcStd = 0.0;
          if (nums.isNotEmpty) {
            final sorted = List<double>.from(nums)..sort();
            final n = sorted.length;
            calcMed = (n % 2 == 1) ? sorted[n ~/ 2] : (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2.0;
            final varSum = nums.fold(0.0, (sum, x) => sum + math.pow(x - calcAvg, 2));
            calcStd = math.sqrt(varSum / n);
          }

          return Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.88,
            child: Column(
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: provider.textColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isChart ? "Chart Data Editor" : "Table Data Editor", style: TextStyle(color: provider.textColor, fontWeight: FontWeight.bold, fontSize: 18)),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            _showTemplatePickerModal(
                              context: context,
                              provider: provider,
                              title: "LOAD TEMPLATE",
                              onSelectTemplate: (template) {
                                setModalState(() {
                                  data = template.data.map((r) => List<String>.from(r)).toList();
                                  selectedCells.clear();
                                  selectedMode = 'All';
                                  _tableGeneration++;
                                });
                              },
                              onSelectBlank: () {},
                            );
                          },
                          icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: MountMapColors.teal),
                          label: const Text("Template", style: TextStyle(color: MountMapColors.teal, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      TextButton.icon(
                        onPressed: () {
                          _showAutoFillDialog(
                            context: context,
                            provider: provider,
                            data: data,
                            selectedCells: selectedCells,
                            activeColumn: activeColumn,
                            activeRow: activeRow,
                            selectedMode: selectedMode,
                            onApplied: () {
                              setModalState(() {
                                _tableGeneration++;
                              });
                            },
                          );
                        },
                        icon: const Icon(Icons.auto_fix_high_rounded, size: 16, color: MountMapColors.violet),
                        label: const Text("Auto-Fill", style: TextStyle(color: MountMapColors.violet, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                        PopupMenuButton<String>(
                          tooltip: 'Table actions',
                          icon: const Icon(Icons.more_vert_rounded, color: MountMapColors.teal),
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'find_replace', child: Row(children: [Icon(Icons.find_replace_rounded, size: 16, color: MountMapColors.teal), SizedBox(width: 8), Text('Find & Replace Text')])),
                            PopupMenuItem(value: 'add_summary_row', child: Row(children: [Icon(Icons.calculate_rounded, size: 16, color: MountMapColors.teal), SizedBox(width: 8), Text('Add Summary Total Row')])),
                            PopupMenuItem(value: 'add_row', child: Row(children: [Icon(Icons.add_rounded, size: 16), SizedBox(width: 8), Text('Add Row Below')])),
                            PopupMenuItem(value: 'add_column', child: Row(children: [Icon(Icons.view_column_rounded, size: 16), SizedBox(width: 8), Text('Add Column Right')])),
                            PopupMenuItem(value: 'export_csv', child: Row(children: [Icon(Icons.file_upload_rounded, size: 16, color: Colors.amberAccent), SizedBox(width: 8), Text('Export to CSV File')])),
                            PopupMenuItem(value: 'import_csv', child: Row(children: [Icon(Icons.file_download_rounded, size: 16, color: Colors.greenAccent), SizedBox(width: 8), Text('Import from CSV File')])),
                            PopupMenuItem(value: 'eval_formulas', child: Row(children: [Icon(Icons.functions_rounded, size: 16, color: MountMapColors.teal), SizedBox(width: 8), Text('Evaluate Formulas (=SUM, =AVG)')])),
                            PopupMenuItem(value: 'clear_selection', child: Row(children: [Icon(Icons.deselect_rounded, size: 16), SizedBox(width: 8), Text('Clear Selection')])),
                            PopupMenuItem(value: 'remove_row', child: Row(children: [Icon(Icons.remove_rounded, size: 16), SizedBox(width: 8), Text('Remove Last Row')])),
                            PopupMenuItem(value: 'remove_column', child: Row(children: [Icon(Icons.view_column_rounded, size: 16), SizedBox(width: 8), Text('Remove Last Column')])),
                          ],
                          onSelected: (value) async {
                            if (value == 'find_replace') {
                              _showFindAndReplaceDialog(
                                context: context,
                                provider: provider,
                                data: data,
                                onApplied: () => setModalState(() => _tableGeneration++),
                              );
                              return;
                            }
                            if (value == 'export_csv') {
                              await _exportTableToCSV(data);
                              return;
                            }
                            if (value == 'import_csv') {
                              final imported = await _importTableFromCSV();
                              if (imported != null && imported.isNotEmpty) {
                                setModalState(() {
                                  data = imported;
                                  _tableGeneration++;
                                });
                              }
                              return;
                            }
                            setModalState(() {
                              if (value == 'add_summary_row' && data.length > 1) {
                                final summaryRow = <String>[];
                                summaryRow.add('TOTAL / SUMMARY');
                                for (int c = 1; c < data[0].length; c++) {
                                  double s = 0;
                                  int count = 0;
                                  for (int r = 1; r < data.length; r++) {
                                    if (c < data[r].length) {
                                      final v = _parseFlexibleNumber(data[r][c]);
                                      if (v != null) {
                                        s += v;
                                        count++;
                                      }
                                    }
                                  }
                                  if (count > 0) {
                                    summaryRow.add(s % 1 == 0 ? s.toInt().toString() : s.toStringAsFixed(2));
                                  } else {
                                    summaryRow.add('-');
                                  }
                                }
                                data.add(summaryRow);
                                _tableGeneration++;
                              } else if (value == 'add_row') {
                                data.add(List.generate(data[0].length, (_) => ""));
                              } else if (value == 'add_column') {
                                for (var r in data) {
                                  r.add("");
                                }
                              } else if (value == 'clear_selection') {
                                selectedCells.clear();
                                selectedMode = 'Selection';
                              } else if (value == 'eval_formulas') {
                                _evaluateExcelFormulas(data);
                                _tableGeneration++;
                              } else if (value == 'remove_row') {
                                if (data.length > 1) {
                                  data.removeLast();
                                }
                              } else if (value == 'remove_column') {
                                if (data.isNotEmpty && data[0].length > 1) {
                                  for (var r in data) {
                                    r.removeLast();
                                  }
                                }
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // LIVE SEARCH ROW FILTER BAR
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    style: TextStyle(color: provider.textColor, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: "Filter rows in table...",
                      hintStyle: TextStyle(color: provider.textColor.withValues(alpha: 0.4), fontSize: 12),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: MountMapColors.teal),
                      suffixIcon: filterQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              onPressed: () => setModalState(() => filterQuery = ""),
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: provider.textColor.withValues(alpha: 0.04),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setModalState(() => filterQuery = val.trim().toLowerCase()),
                  ),
                ),

                // SMART CALCULATOR / MATHEMATICS ANALYTICS BAR
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MountMapColors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: MountMapColors.teal.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: MountMapColors.teal.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.functions_rounded, color: MountMapColors.teal, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "SMART CALCULATOR & ANALYTICS",
                                style: TextStyle(
                                  color: provider.textColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: MountMapColors.teal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              selectedMode == 'Column' && activeColumn != null
                                  ? "Col ${activeColumn! + 1}"
                                  : (selectedMode == 'Row' && activeRow != null
                                      ? "Row ${activeRow! + 1}"
                                      : (selectedMode == 'All' ? "All Cells (${nums.length})" : "Selected (${nums.length})")),
                              style: const TextStyle(color: MountMapColors.teal, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _calcModeChip('Selected', selectedMode == 'Selection', () {
                              setModalState(() => selectedMode = 'Selection');
                            }),
                            const SizedBox(width: 6),
                            _calcModeChip('Col Mode', selectedMode == 'Column', () {
                              setModalState(() {
                                selectedMode = 'Column';
                                activeColumn ??= 0;
                              });
                            }),
                            const SizedBox(width: 6),
                            _calcModeChip('Row Mode', selectedMode == 'Row', () {
                              setModalState(() {
                                selectedMode = 'Row';
                                activeRow ??= 1;
                              });
                            }),
                            const SizedBox(width: 6),
                            _calcModeChip('All Cells', selectedMode == 'All', () {
                              setModalState(() => selectedMode = 'All');
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _calcStatBadge("SUM", calcSum % 1 == 0 ? calcSum.toInt().toString() : calcSum.toStringAsFixed(2), Colors.greenAccent),
                            _calcStatBadge("AVG", calcAvg % 1 == 0 ? calcAvg.toInt().toString() : calcAvg.toStringAsFixed(2), Colors.cyanAccent),
                            _calcStatBadge("COUNT", calcCount.toString(), Colors.amberAccent),
                            _calcStatBadge("MIN", calcMin % 1 == 0 ? calcMin.toInt().toString() : calcMin.toStringAsFixed(2), Colors.orangeAccent),
                            _calcStatBadge("MAX", calcMax % 1 == 0 ? calcMax.toInt().toString() : calcMax.toStringAsFixed(2), Colors.redAccent),
                            _calcStatBadge("MEDIAN", calcMed % 1 == 0 ? calcMed.toInt().toString() : calcMed.toStringAsFixed(2), Colors.purpleAccent),
                            _calcStatBadge("STD DEV", calcStd % 1 == 0 ? calcStd.toInt().toString() : calcStd.toStringAsFixed(2), Colors.blueAccent),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - 64,
                        ),
                        child: Column(
                          children: [
                            // Column Actions Header
                            Row(
                              children: [
                                const SizedBox(width: 40), // Row action column offset
                                ...List.generate(data[0].length, (cIdx) {
                                  final isColSelected = selectedMode == 'Column' && activeColumn == cIdx;
                                  return SizedBox(
                                    width: isChart ? 170 : 220,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setModalState(() {
                                              selectedMode = 'Column';
                                              activeColumn = cIdx;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isColSelected ? MountMapColors.teal : Colors.transparent,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "COL ${cIdx + 1}",
                                              style: TextStyle(
                                                color: isColSelected ? Colors.white : provider.textColor.withValues(alpha: 0.5),
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.more_horiz_rounded, size: 16, color: provider.textColor.withValues(alpha: 0.3)),
                                          onSelected: (value) {
                                            setModalState(() {
                                              _tableGeneration++;
                                              if (value == 'move_left' && cIdx > 0) {
                                                for (var r in data) {
                                                  final temp = r[cIdx];
                                                  r[cIdx] = r[cIdx - 1];
                                                  r[cIdx - 1] = temp;
                                                }
                                              } else if (value == 'move_right' && cIdx < data[0].length - 1) {
                                                for (var r in data) {
                                                  final temp = r[cIdx];
                                                  r[cIdx] = r[cIdx + 1];
                                                  r[cIdx + 1] = temp;
                                                }
                                              } else if (value == 'duplicate') {
                                                for (var r in data) {
                                                  r.insert(cIdx + 1, r[cIdx]);
                                                }
                                              } else if (value == 'delete' && data[0].length > 1) {
                                                for (var r in data) {
                                                  r.removeAt(cIdx);
                                                }
                                              } else if (value == 'sort_asc' && data.length > 2) {
                                                final header = data.first;
                                                final body = data.sublist(1);
                                                body.sort((a, b) {
                                                  final valA = cIdx < a.length ? a[cIdx] : '';
                                                  final valB = cIdx < b.length ? b[cIdx] : '';
                                                  final numA = _parseFlexibleNumber(valA);
                                                  final numB = _parseFlexibleNumber(valB);
                                                  if (numA != null && numB != null) return numA.compareTo(numB);
                                                  return valA.toLowerCase().compareTo(valB.toLowerCase());
                                                });
                                                data = [header, ...body];
                                              } else if (value == 'sort_desc' && data.length > 2) {
                                                final header = data.first;
                                                final body = data.sublist(1);
                                                body.sort((a, b) {
                                                  final valA = cIdx < a.length ? a[cIdx] : '';
                                                  final valB = cIdx < b.length ? b[cIdx] : '';
                                                  final numA = _parseFlexibleNumber(valA);
                                                  final numB = _parseFlexibleNumber(valB);
                                                  if (numA != null && numB != null) return numB.compareTo(numA);
                                                  return valB.toLowerCase().compareTo(valA.toLowerCase());
                                                });
                                                data = [header, ...body];
                                              } else if (value == 'sum_column') {
                                                double s = 0;
                                                for (int r = 1; r < data.length; r++) {
                                                  s += _parseFlexibleNumber(data[r][cIdx]) ?? 0;
                                                }
                                                data.add(List.generate(data[0].length, (index) => index == 0 ? "TOTAL COL ${cIdx + 1}" : (index == cIdx ? s.toStringAsFixed(1) : "-")));
                                              }
                                            });
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(value: 'sort_asc', child: Row(children: [Icon(Icons.sort_by_alpha_rounded, size: 16, color: MountMapColors.teal), SizedBox(width: 8), Text('Sort Ascending (A-Z / 0-9)')])),
                                            const PopupMenuItem(value: 'sort_desc', child: Row(children: [Icon(Icons.sort_by_alpha_rounded, size: 16, color: MountMapColors.violet), SizedBox(width: 8), Text('Sort Descending (Z-A / 9-0)')])),
                                            const PopupMenuItem(value: 'sum_column', child: Row(children: [Icon(Icons.functions_rounded, size: 16, color: MountMapColors.teal), SizedBox(width: 8), Text('Add Total Row')])),
                                            const PopupMenuItem(value: 'move_left', child: Row(children: [Icon(Icons.arrow_back_rounded, size: 16), SizedBox(width: 8), Text('Move Left')])),
                                            const PopupMenuItem(value: 'move_right', child: Row(children: [Icon(Icons.arrow_forward_rounded, size: 16), SizedBox(width: 8), Text('Move Right')])),
                                            const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.copy_rounded, size: 16), SizedBox(width: 8), Text('Duplicate Column')])),
                                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent), SizedBox(width: 8), Text('Delete Column', style: TextStyle(color: Colors.redAccent))])),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                            ...data.asMap().entries.where((rowEntry) {
                              if (rowEntry.key == 0 || filterQuery.isEmpty) return true;
                              return rowEntry.value.any((cell) => cell.toLowerCase().contains(filterQuery));
                            }).map((rowEntry) {
                              final int rIdx = rowEntry.key;
                              final isRowSelected = selectedMode == 'Row' && activeRow == rIdx;

                              return Container(
                                decoration: BoxDecoration(
                                  color: rIdx == 0
                                      ? MountMapColors.teal.withValues(alpha: 0.1)
                                      : (isRowSelected ? MountMapColors.teal.withValues(alpha: 0.15) : null),
                                  border: Border(
                                    left: BorderSide(color: provider.textColor.withValues(alpha: 0.1)),
                                    right: BorderSide(color: provider.textColor.withValues(alpha: 0.1)),
                                    top: BorderSide(color: provider.textColor.withValues(alpha: 0.1)),
                                    bottom: BorderSide(color: provider.textColor.withValues(alpha: 0.1)),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row Actions & Row Selector
                                    SizedBox(
                                      width: 40,
                                      child: Center(
                                        child: InkWell(
                                          onTap: rIdx == 0 ? null : () {
                                            setModalState(() {
                                              selectedMode = 'Row';
                                              activeRow = rIdx;
                                            });
                                          },
                                          child: PopupMenuButton<String>(
                                            padding: EdgeInsets.zero,
                                            icon: Icon(Icons.more_vert_rounded, size: 16, color: isRowSelected ? MountMapColors.teal : provider.textColor.withValues(alpha: 0.3)),
                                            onSelected: (value) {
                                              setModalState(() {
                                                _tableGeneration++;
                                                if (value == 'move_up' && rIdx > 0) {
                                                  final temp = data[rIdx];
                                                  data[rIdx] = data[rIdx - 1];
                                                  data[rIdx - 1] = temp;
                                                } else if (value == 'move_down' && rIdx < data.length - 1) {
                                                  final temp = data[rIdx];
                                                  data[rIdx] = data[rIdx + 1];
                                                  data[rIdx + 1] = temp;
                                                } else if (value == 'duplicate') {
                                                  data.insert(rIdx + 1, List<String>.from(data[rIdx]));
                                                } else if (value == 'delete' && data.length > 1) {
                                                  data.removeAt(rIdx);
                                                } else if (value == 'sum_row') {
                                                  double s = 0;
                                                  for (int c = 1; c < data[rIdx].length; c++) {
                                                    s += _parseFlexibleNumber(data[rIdx][c]) ?? 0;
                                                  }
                                                  data[rIdx].add(s.toStringAsFixed(1));
                                                  if (rIdx == 0) data[0][data[0].length - 1] = "TOTAL ROW";
                                                }
                                              });
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(value: 'sum_row', child: Row(children: [Icon(Icons.functions_rounded, size: 16, color: MountMapColors.teal), SizedBox(width: 8), Text('Add Row Sum Col')])),
                                              const PopupMenuItem(value: 'move_up', child: Row(children: [Icon(Icons.arrow_upward_rounded, size: 16), SizedBox(width: 8), Text('Move Up')])),
                                              const PopupMenuItem(value: 'move_down', child: Row(children: [Icon(Icons.arrow_downward_rounded, size: 16), SizedBox(width: 8), Text('Move Down')])),
                                              const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.copy_rounded, size: 16), SizedBox(width: 8), Text('Duplicate Row')])),
                                              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent), SizedBox(width: 8), Text('Delete Row', style: TextStyle(color: Colors.redAccent))])),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    ...rowEntry.value.asMap().entries.map((colEntry) {
                                      final int cIdx = colEntry.key;
                                      final cellKey = "${rIdx}_${cIdx}";
                                      final isCellSelected = selectedCells.contains(cellKey);
                                      final bool isAttachmentCell = _isTableAttachmentValue(colEntry.value);
                                      final String displayValue = _displayTableCellValue(colEntry.value);

                                      final isEditingCell = editingCellKey == cellKey;

                                      return InkWell(
                                        onTap: () {
                                          setModalState(() {
                                            if (selectedMode != 'Selection') {
                                              selectedMode = 'Selection';
                                              selectedCells.clear();
                                            }
                                            if (selectedCells.contains(cellKey)) {
                                              selectedCells.remove(cellKey);
                                            } else {
                                              selectedCells.add(cellKey);
                                            }
                                            if (editingCellKey != cellKey) {
                                              editingCellKey = null;
                                            }
                                          });
                                        },
                                        onDoubleTap: () {
                                          setModalState(() {
                                            editingCellKey = cellKey;
                                            selectedCells.add(cellKey);
                                          });
                                        },
                                        child: Container(
                                          width: isChart ? 170 : 220,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isCellSelected ? MountMapColors.teal.withValues(alpha: 0.25) : Colors.transparent,
                                            border: Border(
                                              right: BorderSide(color: isEditingCell ? MountMapColors.teal : provider.textColor.withValues(alpha: 0.08)),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: isEditingCell
                                                    ? TextFormField(
                                                        key: ValueKey('cell_edit_${rIdx}_${cIdx}_$_tableGeneration'),
                                                        initialValue: displayValue,
                                                        autofocus: true,
                                                        readOnly: isAttachmentCell,
                                                        style: TextStyle(
                                                          color: provider.textColor,
                                                          fontSize: 13,
                                                          fontWeight: rIdx == 0 ? FontWeight.bold : FontWeight.normal,
                                                        ),
                                                        minLines: 1,
                                                        maxLines: null,
                                                        decoration: const InputDecoration(
                                                          border: InputBorder.none,
                                                          isDense: true,
                                                          contentPadding: EdgeInsets.zero,
                                                        ),
                                                        onChanged: (val) => data[rIdx][cIdx] = val,
                                                      )
                                                    : Text(
                                                        displayValue.isEmpty ? "-" : displayValue,
                                                        style: TextStyle(
                                                          color: isAttachmentCell
                                                              ? MountMapColors.teal
                                                              : (displayValue.isEmpty ? provider.textColor.withValues(alpha: 0.3) : provider.textColor),
                                                          fontSize: 13,
                                                          fontWeight: rIdx == 0 ? FontWeight.bold : FontWeight.normal,
                                                        ),
                                                      ),
                                              ),
                                              PopupMenuButton<String>(
                                                icon: Icon(Icons.more_vert_rounded, size: 16, color: provider.textColor.withValues(alpha: 0.65)),
                                                tooltip: 'Cell actions',
                                                onSelected: (value) async {
                                                  if (value == 'move_left' && cIdx > 0) {
                                                    setModalState(() {
                                                      _tableGeneration++;
                                                      final temp = data[rIdx][cIdx];
                                                      data[rIdx][cIdx] = data[rIdx][cIdx - 1];
                                                      data[rIdx][cIdx - 1] = temp;
                                                    });
                                                    return;
                                                  }
                                                  if (value == 'move_right' && cIdx < data[rIdx].length - 1) {
                                                    setModalState(() {
                                                      _tableGeneration++;
                                                      final temp = data[rIdx][cIdx];
                                                      data[rIdx][cIdx] = data[rIdx][cIdx + 1];
                                                      data[rIdx][cIdx + 1] = temp;
                                                    });
                                                    return;
                                                  }
                                                  if (value == 'move_up' && rIdx > 0) {
                                                    setModalState(() {
                                                      _tableGeneration++;
                                                      final temp = data[rIdx][cIdx];
                                                      data[rIdx][cIdx] = data[rIdx - 1][cIdx];
                                                      data[rIdx - 1][cIdx] = temp;
                                                    });
                                                    return;
                                                  }
                                                  if (value == 'move_down' && rIdx < data.length - 1) {
                                                    setModalState(() {
                                                      _tableGeneration++;
                                                      final temp = data[rIdx][cIdx];
                                                      data[rIdx][cIdx] = data[rIdx + 1][cIdx];
                                                      data[rIdx + 1][cIdx] = temp;
                                                    });
                                                    return;
                                                  }

                                                  if (value == 'formula_sum') {
                                                    setModalState(() {
                                                      double s = 0;
                                                      for (int r = 1; r < rIdx; r++) {
                                                        s += _parseFlexibleNumber(data[r][cIdx]) ?? 0;
                                                      }
                                                      data[rIdx][cIdx] = s % 1 == 0 ? s.toInt().toString() : s.toStringAsFixed(2);
                                                      _tableGeneration++;
                                                    });
                                                    return;
                                                  }
                                                  if (value == 'formula_avg') {
                                                    setModalState(() {
                                                      final nums = _extractColumnNumbers(data, cIdx, rIdx);
                                                      final avg = nums.isNotEmpty ? nums.fold(0.0, (a, b) => a + b) / nums.length : 0.0;
                                                      data[rIdx][cIdx] = avg % 1 == 0 ? avg.toInt().toString() : avg.toStringAsFixed(2);
                                                      _tableGeneration++;
                                                    });
                                                    return;
                                                  }
                                                  if (value == 'formula_max') {
                                                    setModalState(() {
                                                      final nums = _extractColumnNumbers(data, cIdx, rIdx);
                                                      final max = nums.isNotEmpty ? nums.reduce((a, b) => a > b ? a : b) : 0.0;
                                                      data[rIdx][cIdx] = max % 1 == 0 ? max.toInt().toString() : max.toStringAsFixed(2);
                                                      _tableGeneration++;
                                                    });
                                                    return;
                                                  }
                                                  if (value == 'formula_min') {
                                                    setModalState(() {
                                                      final nums = _extractColumnNumbers(data, cIdx, rIdx);
                                                      final min = nums.isNotEmpty ? nums.reduce((a, b) => a < b ? a : b) : 0.0;
                                                      data[rIdx][cIdx] = min % 1 == 0 ? min.toInt().toString() : min.toStringAsFixed(2);
                                                      _tableGeneration++;
                                                    });
                                                    return;
                                                  }
                                                  if (value == 'set_checkbox_done') {
                                                    setModalState(() {
                                                      data[rIdx][cIdx] = '[x]';
                                                      _tableGeneration++;
                                                    });
                                                    return;
                                                  }
                                                  if (value == 'set_checkbox_todo') {
                                                    setModalState(() {
                                                      data[rIdx][cIdx] = '[ ]';
                                                      _tableGeneration++;
                                                    });
                                                    return;
                                                  }
                                                  if (value == 'set_rating_stars') {
                                                    setModalState(() {
                                                      data[rIdx][cIdx] = '5/5';
                                                      _tableGeneration++;
                                                    });
                                                    return;
                                                  }
                                                  if (value == 'mask_password') {
                                                    setModalState(() {
                                                      if (data[rIdx][cIdx].contains('•')) {
                                                        data[rIdx][cIdx] = 'Password123';
                                                      } else {
                                                        data[rIdx][cIdx] = '••••••••••••';
                                                      }
                                                      _tableGeneration++;
                                                    });
                                                    return;
                                                  }
                                                  if (value == 'attach_file') {
                                                    await _pickFileForTableCell(provider, data, rIdx, cIdx, setModalState);
                                                    return;
                                                  }
                                                  if (value == 'attach_link') {
                                                    _showAddLinkForTableCell(provider, data, rIdx, cIdx, setModalState);
                                                    return;
                                                  }
                                                  if (value == 'open' && isAttachmentCell) {
                                                    await _openTableCellValue(colEntry.value);
                                                    return;
                                                  }
                                                  if (value == 'clear_attachment' && isAttachmentCell) {
                                                    setModalState(() {
                                                      data[rIdx][cIdx] = '';
                                                    });
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(value: 'move_left', child: Row(children: [Icon(Icons.arrow_back_rounded, size: 16), SizedBox(width: 8), Text('Move Cell Left')])),
                                                  const PopupMenuItem(value: 'move_right', child: Row(children: [Icon(Icons.arrow_forward_rounded, size: 16), SizedBox(width: 8), Text('Move Cell Right')])),
                                                  const PopupMenuItem(value: 'move_up', child: Row(children: [Icon(Icons.arrow_upward_rounded, size: 16), SizedBox(width: 8), Text('Move Cell Up')])),
                                                  const PopupMenuItem(value: 'move_down', child: Row(children: [Icon(Icons.arrow_downward_rounded, size: 16), SizedBox(width: 8), Text('Move Cell Down')])),
                                                  if (rIdx != 0)
                                                    const PopupMenuItem(
                                                      value: 'formula_sum',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.functions_rounded, size: 16, color: MountMapColors.teal),
                                                          SizedBox(width: 8),
                                                          Text('Quick Sum (Col Above)'),
                                                        ],
                                                      ),
                                                    ),
                                                  if (rIdx != 0)
                                                    const PopupMenuItem(
                                                      value: 'formula_avg',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.analytics_rounded, size: 16, color: MountMapColors.teal),
                                                          SizedBox(width: 8),
                                                          Text('Quick Avg (Col Above)'),
                                                        ],
                                                      ),
                                                    ),
                                                  if (rIdx != 0)
                                                    const PopupMenuItem(
                                                      value: 'set_checkbox_done',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.check_box_rounded, size: 16, color: Colors.greenAccent),
                                                          SizedBox(width: 8),
                                                          Text('Set Checkbox [x]'),
                                                        ],
                                                      ),
                                                    ),
                                                  if (rIdx != 0)
                                                    const PopupMenuItem(
                                                      value: 'set_checkbox_todo',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.check_box_outline_blank_rounded, size: 16),
                                                          SizedBox(width: 8),
                                                          Text('Set Checkbox [ ]'),
                                                        ],
                                                      ),
                                                    ),
                                                  if (rIdx != 0)
                                                    const PopupMenuItem(
                                                      value: 'set_rating_stars',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.star_rounded, size: 16, color: Colors.amberAccent),
                                                          SizedBox(width: 8),
                                                          Text('Set Rating Stars (5/5)'),
                                                        ],
                                                      ),
                                                    ),
                                                  if (rIdx != 0)
                                                    const PopupMenuItem(
                                                      value: 'mask_password',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.lock_rounded, size: 16, color: MountMapColors.violet),
                                                          SizedBox(width: 8),
                                                          Text('Mask / Hide Value'),
                                                        ],
                                                      ),
                                                    ),
                                                  if (rIdx != 0)
                                                    const PopupMenuItem(
                                                      value: 'attach_file',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.attach_file_rounded, size: 16),
                                                          SizedBox(width: 8),
                                                          Text('Attach File'),
                                                        ],
                                                      ),
                                                    ),
                                                  if (rIdx != 0)
                                                    const PopupMenuItem(
                                                      value: 'attach_link',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.link_rounded, size: 16),
                                                          SizedBox(width: 8),
                                                          Text('Attach Link'),
                                                        ],
                                                      ),
                                                    ),
                                                  if (rIdx != 0 && isAttachmentCell)
                                                    const PopupMenuItem(
                                                      value: 'open',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.open_in_new_rounded, size: 16),
                                                          SizedBox(width: 8),
                                                          Text('Open Attachment'),
                                                        ],
                                                      ),
                                                    ),
                                                  if (rIdx != 0 && isAttachmentCell)
                                                    const PopupMenuItem(
                                                      value: 'clear_attachment',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.clear_rounded, size: 16),
                                                          SizedBox(width: 8),
                                                          Text('Clear Attachment'),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: MountMapColors.teal, foregroundColor: Colors.white),
                    onPressed: () {
                      provider.updateDescriptionBlock(nodeId, blockId, tableData: data);
                      Navigator.pop(context);
                    },
                    child: const Text("SAVE CHANGES"),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _calcModeChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? MountMapColors.teal : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _calcStatBadge(String label, String val, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$label: ", style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MountMapProvider>(context);
    final isDark = provider.currentTheme == AppThemeMode.dark;
    final textColor = provider.textColor;
    final cardColor = provider.cardColor;

    // Always get the freshest node data from provider
    NodeModel? node;
    try {
      node = provider.nodes.firstWhere((n) => n.id == widget.node.id);
    } catch (e) {
      node = widget.node;
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      width: MediaQuery.of(context).size.width > 600 ? 550 : double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(node.text, textColor, isDark),
          Flexible(
            child: ReorderableListView(
              padding: const EdgeInsets.all(24),
              onReorder: (oldIndex, newIndex) {
                if (oldIndex >= node!.descriptionBlocks.length) return;
                final targetIndex = newIndex > node.descriptionBlocks.length
                    ? node.descriptionBlocks.length
                    : newIndex;
                provider.reorderDescriptionBlock(node.id, oldIndex, targetIndex);
              },
              children: [
                ...node.descriptionBlocks.asMap().entries.map((entry) {
                  final blockNumber = _getBlockTypeSequence(node!.descriptionBlocks, entry.key);
                  return _buildBlock(
                    key: ValueKey(entry.value.id),
                    entry.value,
                    provider,
                    node!,
                    textColor,
                    isDark,
                    entry.key,
                    blockNumber,
                  );
                }),

                Container(
                  key: const ValueKey('tags_section'),
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("TAGS", Icons.sell_outlined, textColor),
                      const SizedBox(height: 12),
                      _buildTags(node, provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildFooter(provider),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MountMapColors.teal,
            MountMapColors.violet,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: MountMapColors.teal),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.4),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBlock(DescriptionBlock block, MountMapProvider provider, NodeModel node, Color textColor, bool isDark, int index, int blockNumber, {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(Icons.drag_indicator_rounded, size: 20, color: textColor.withValues(alpha: 0.2)),
                  ),
                  const SizedBox(width: 8),
                  _buildSectionTitle('${_getBlockTypeLabel(block.type).toUpperCase()} $blockNumber', _getIconForType(block.type), textColor),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isBlockVaultLocked(block.id) ? Icons.lock_rounded : Icons.lock_open_rounded,
                      size: 16,
                      color: _isBlockVaultLocked(block.id) ? MountMapColors.violet : textColor.withValues(alpha: 0.4),
                    ),
                    tooltip: _isBlockVaultLocked(block.id) ? "Vault Locked (Tap to Unlock)" : "Lock Vault with Biometrics",
                    onPressed: () {
                      if (_isBlockVaultLocked(block.id)) {
                        _unlockBlockVault(block.id);
                      } else {
                        setState(() {
                          _lockedBlockIds.add(block.id);
                          _unlockedBlockIds.remove(block.id);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Block Vault Locked"), backgroundColor: MountMapColors.violet),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.copy_rounded, size: 16, color: textColor.withValues(alpha: 0.5)),
                    onPressed: () => provider.duplicateDescriptionBlock(node.id, block.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                    onPressed: () => provider.removeDescriptionBlock(node.id, block.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildBlockContent(block, provider, node, textColor, isDark),
        ],
      ),
    );
  }

  IconData _getIconForType(BlockType type) {
    switch (type) {
      case BlockType.text: return Icons.notes_rounded;
      case BlockType.attachment: return Icons.attach_file_rounded;
      case BlockType.table: return Icons.table_chart_rounded;
      case BlockType.chart: return Icons.bar_chart_rounded;
    }
  }

  int _getBlockTypeSequence(List<DescriptionBlock> blocks, int currentIndex) {
    final currentType = blocks[currentIndex].type;
    int sequence = 0;

    for (int i = 0; i <= currentIndex; i++) {
      if (blocks[i].type == currentType) {
        sequence++;
      }
    }

    return sequence;
  }

  String _getBlockTypeLabel(BlockType type) {
    switch (type) {
      case BlockType.text:
        return 'Text';
      case BlockType.attachment:
        return 'Attachment';
      case BlockType.table:
        return 'Table';
      case BlockType.chart:
        return 'Chart';
    }
  }

  Widget _buildBlockContent(DescriptionBlock block, MountMapProvider provider, NodeModel node, Color textColor, bool isDark) {
    if (_isBlockVaultLocked(block.id)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: MountMapColors.violet.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MountMapColors.violet.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            const Icon(Icons.security_rounded, size: 36, color: MountMapColors.violet),
            const SizedBox(height: 10),
            Text(
              "CREDENTIAL & SENSITIVE VAULT LOCKED",
              style: TextStyle(color: provider.textColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            Text(
              "Gunakan Sensor Biometrik / PIN HP untuk membuka isi data ini.",
              style: TextStyle(color: provider.textColor.withValues(alpha: 0.5), fontSize: 10),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: MountMapColors.violet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.fingerprint_rounded, size: 18),
              label: const Text("UNLOCK VAULT"),
              onPressed: () => _unlockBlockVault(block.id),
            ),
          ],
        ),
      );
    }

    switch (block.type) {
      case BlockType.text:
        return _buildTextBlock(block, provider, node, textColor);
      case BlockType.attachment:
        return _buildAttachmentBlock(block, provider, node);
      case BlockType.table:
        return _buildTableBlock(block, provider, node, textColor);
      case BlockType.chart:
        return _buildChartBlock(block, provider, node);
    }
  }

  Widget _buildTextBlock(DescriptionBlock block, MountMapProvider provider, NodeModel node, Color textColor) {
    final isEditing = _editingBlockId == block.id;
    if (!isEditing) {
      return InkWell(
        onTap: () => setState(() => _editingBlockId = block.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: textColor.withValues(alpha: 0.05)),
          ),
          child: Text(
            block.content?.isNotEmpty == true ? block.content! : "Tap to add text...",
            style: TextStyle(
              color: block.content?.isNotEmpty == true ? textColor.withValues(alpha: 0.8) : textColor.withValues(alpha: 0.3),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      );
    }

    return _TextBlockEditor(
      initialContent: block.content ?? "",
      textColor: textColor,
      onSave: (val) {
        provider.updateDescriptionBlock(node.id, block.id, content: val);
        setState(() => _editingBlockId = null);
      },
      onCancel: () => setState(() => _editingBlockId = null),
    );
  }

  Widget _buildAttachmentBlock(DescriptionBlock block, MountMapProvider provider, NodeModel node) {
    final item = block.attachment;
    if (item == null) return const SizedBox();

    final isLink = item.type == 'link';
    IconData icon = Icons.insert_drive_file_rounded;
    Color iconColor = Colors.blueAccent;

    if (isLink) {
      icon = Icons.link_rounded;
      iconColor = Colors.indigoAccent;
    } else {
      final ext = item.value.toLowerCase();
      if (ext.endsWith('.mp3') || ext.endsWith('.wav')) {
        icon = Icons.audiotrack_rounded;
        iconColor = Colors.orangeAccent;
      } else if (ext.endsWith('.mp4') || ext.endsWith('.mov')) {
        icon = Icons.videocam_rounded;
        iconColor = Colors.redAccent;
      } else if (ext.endsWith('.jpg') || ext.endsWith('.png')) {
        icon = Icons.image_rounded;
        iconColor = Colors.greenAccent;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: provider.textColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: provider.textColor.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: () => _openAttachment(item),
        dense: true,
        leading: Icon(icon, color: iconColor, size: 20),
        title: Text(item.name, style: TextStyle(color: provider.textColor, fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text(isLink ? item.value : "LOCAL FILE", style: TextStyle(color: provider.textColor.withValues(alpha: 0.4), fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Icon(Icons.open_in_new_rounded, size: 14, color: provider.textColor.withValues(alpha: 0.3)),
      ),
    );
  }

  Future<void> _openAttachment(AttachmentItem item) async {
    try {
      if (item.type == 'link') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AttachmentViewerScreen(item: item)),
        );
      } else {
        final path = item.value.toLowerCase();
        final supportedExt = [
          '.jpg', '.jpeg', '.png', '.webp',
          '.txt',
          '.mp3', '.wav', '.m4a',
          '.mp4', '.mp5', '.mov', '.mkv'
        ];

        bool isInAppSupported = supportedExt.any((ext) => path.endsWith(ext));

        if (isInAppSupported) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttachmentViewerScreen(
                item: AttachmentItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: item.name,
                  value: item.value,
                  type: 'file',
                ),
              ),
            ),
          );
        } else {
          await _openFileExternally(item.value);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cannot open item: $e"), backgroundColor: Colors.red));
    }
  }

  Future<void> _openFileExternally(String path) async {
    final result = await OpenFile.open(path);
    if (!mounted) return;

    if (result.type == ResultType.noAppToOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada aplikasi untuk membuka file ini (PDF/DOCX/PPT). Install viewer yang sesuai.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka file: ${result.message}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildTableBlock(DescriptionBlock block, MountMapProvider provider, NodeModel node, Color textColor) {
    final tableData = block.tableData ?? [];
    final GlobalKey tableRepaintKey = GlobalKey();

    return Column(
      children: [
        RepaintBoundary(
          key: tableRepaintKey,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: provider.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: textColor.withValues(alpha: 0.05)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder.all(color: textColor.withValues(alpha: 0.1), width: 0.5),
              children: tableData.asMap().entries.map((rowEntry) {
                final rIdx = rowEntry.key;
                return TableRow(
                  children: rowEntry.value.asMap().entries.map((colEntry) {
                    final cIdx = colEntry.key;
                    final cellVal = colEntry.value;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 110, maxWidth: 280),
                        child: _renderSmartTableCell(
                          cellVal,
                          textColor: textColor,
                          isHeader: rIdx == 0,
                          onTap: _isTableAttachmentValue(cellVal) ? () => _openTableCellValue(cellVal) : null,
                          onToggleCheckbox: (newVal) {
                            final updated = tableData.map((r) => List<String>.from(r)).toList();
                            updated[rIdx][cIdx] = newVal;
                            provider.updateDescriptionBlock(node.id, block.id, tableData: updated);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: MountMapColors.teal),
                  label: const Text("Template", style: TextStyle(fontSize: 12, color: MountMapColors.teal)),
                  onPressed: () {
                    _showTemplatePickerModal(
                      context: context,
                      provider: provider,
                      title: "APPLY TEMPLATE TO TABLE",
                      onSelectTemplate: (template) {
                        provider.updateDescriptionBlock(node.id, block.id, tableData: template.data.map((r) => List<String>.from(r)).toList());
                      },
                      onSelectBlank: () {},
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.sync_alt_rounded, size: 14, color: MountMapColors.violet),
                  label: const Text("Sync Node Data", style: TextStyle(fontSize: 12, color: MountMapColors.violet)),
                  onPressed: () {
                    if (node.tableData != null && node.tableData!.isNotEmpty) {
                      provider.updateDescriptionBlock(node.id, block.id, tableData: node.tableData!.map((r) => List<String>.from(r)).toList());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Table synced with Main Node Data!"), backgroundColor: MountMapColors.teal),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Main Node Data is empty."), backgroundColor: Colors.orangeAccent),
                      );
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image_rounded, size: 16, color: Colors.amberAccent),
                  tooltip: "Export Table PNG Image",
                  onPressed: () => _exportEmbeddedChartToPNG(tableRepaintKey, "Table"),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit_rounded, size: 14),
                  label: const Text("Edit Table", style: TextStyle(fontSize: 12)),
                  onPressed: () => _showTableEditor(provider, node.id, block.id),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget _buildChartBlock(DescriptionBlock block, MountMapProvider provider, NodeModel node) {
    final chartData = block.tableData ?? const [];
    final rowCount = chartData.length > 1 ? chartData.length - 1 : 0;
    final chartState = _getChartState(block.id);
    final GlobalKey chartRepaintKey = GlobalKey();

    // Compute basic statistics if numerical values exist
    final stats = _computeChartStats(chartData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: provider.textColor.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: provider.textColor.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.insights_rounded, color: chartState['primaryColor'] as Color, size: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            (block.chartType ?? "Chart").toUpperCase(),
                            style: TextStyle(
                              color: provider.textColor.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: MountMapColors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$rowCount rows',
                      style: const TextStyle(
                        color: MountMapColors.teal,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.fullscreen_rounded, size: 20, color: MountMapColors.teal),
                    tooltip: "Full Screen Interactive View",
                    onPressed: () => _openFullscreenChartModal(provider, block),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Mini Toolbar for Interactive Customization directly in Description
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chartMiniToggle(
                      label: "Stats",
                      icon: Icons.analytics_outlined,
                      isActive: chartState['showStats'] as bool,
                      onToggle: () => setState(() => chartState['showStats'] = !(chartState['showStats'] as bool)),
                    ),
                    const SizedBox(width: 6),
                    _chartMiniToggle(
                      label: "Trend",
                      icon: Icons.show_chart_rounded,
                      isActive: chartState['showTrend'] as bool,
                      onToggle: () => setState(() => chartState['showTrend'] = !(chartState['showTrend'] as bool)),
                    ),
                    const SizedBox(width: 6),
                    _chartColorPresetChip(
                      name: "MountMap Teal",
                      p: MountMapColors.teal,
                      s: MountMapColors.violet,
                      onSelect: () => setState(() {
                        chartState['primaryColor'] = MountMapColors.teal;
                        chartState['secondaryColor'] = MountMapColors.violet;
                      }),
                    ),
                    const SizedBox(width: 4),
                    _chartColorPresetChip(
                      name: "Emerald",
                      p: Colors.greenAccent,
                      s: Colors.tealAccent,
                      onSelect: () => setState(() {
                        chartState['primaryColor'] = Colors.greenAccent;
                        chartState['secondaryColor'] = Colors.tealAccent;
                      }),
                    ),
                    const SizedBox(width: 4),
                    _chartColorPresetChip(
                      name: "Royal Gold",
                      p: const Color(0xFFFFD700),
                      s: const Color(0xFF000080),
                      onSelect: () => setState(() {
                        chartState['primaryColor'] = const Color(0xFFFFD700);
                        chartState['secondaryColor'] = const Color(0xFF000080);
                      }),
                    ),
                    const SizedBox(width: 4),
                    _chartColorPresetChip(
                      name: "Cyber Neon",
                      p: Colors.cyanAccent,
                      s: Colors.purpleAccent,
                      onSelect: () => setState(() {
                        chartState['primaryColor'] = Colors.cyanAccent;
                        chartState['secondaryColor'] = Colors.purpleAccent;
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // RepaintBoundary for PNG Exporting
              RepaintBoundary(
                key: chartRepaintKey,
                child: Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: provider.currentTheme == AppThemeMode.dark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: provider.textColor.withValues(alpha: 0.08)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: ChartEnginePainter(
                        chartType: block.chartType ?? 'rose chart',
                        data: NodeModel(id: 'temp', text: '', position: Offset.zero, tableData: block.tableData),
                        primaryColor: chartState['primaryColor'] as Color,
                        secondaryColor: chartState['secondaryColor'] as Color,
                        showStats: chartState['showStats'] as bool,
                        showTrend: chartState['showTrend'] as bool,
                        isDark: provider.currentTheme == AppThemeMode.dark,
                        visualSettings: {
                          'intensity': chartState['intensity'] as double,
                          'thickness': chartState['thickness'] as double,
                          'opacity': chartState['opacity'] as double,
                        },
                      ),
                    ),
                  ),
                ),
              ),

              if (stats != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: MountMapColors.teal.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: MountMapColors.teal.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statBadge("SUM", stats.sum.toStringAsFixed(1)),
                      _statBadge("AVG", stats.avg.toStringAsFixed(1)),
                      _statBadge("MAX", stats.max.toStringAsFixed(1)),
                      _statBadge("MIN", stats.min.toStringAsFixed(1)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: MountMapColors.teal),
              label: const Text("Template"),
              onPressed: () {
                _showTemplatePickerModal(
                  context: context,
                  provider: provider,
                  title: "LOAD TEMPLATE TO CHART",
                  onSelectTemplate: (template) {
                    provider.updateDescriptionBlock(
                      node.id,
                      block.id,
                      chartType: template.recommendedChartType,
                      tableData: template.data.map((r) => List<String>.from(r)).toList(),
                    );
                  },
                  onSelectBlank: () {},
                );
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.psychology_rounded, size: 14, color: MountMapColors.violet),
              label: const Text("AI Insights", style: TextStyle(color: MountMapColors.violet)),
              onPressed: () => _showAIInsightsModal(provider, block),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.type_specimen_rounded, size: 14),
              label: const Text("Chart Type"),
              onPressed: () => _showChartTypePickerForExistingBlock(provider, node.id, block.id),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.image_rounded, size: 14, color: Colors.amber),
              label: const Text("Export PNG"),
              onPressed: () => _exportEmbeddedChartToPNG(chartRepaintKey, block.chartType ?? 'Chart'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: MountMapColors.teal,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.edit_rounded, size: 14),
              label: const Text("Edit Data"),
              onPressed: () => _showTableEditor(provider, node.id, block.id, isChart: true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chartMiniToggle({required String label, required IconData icon, required bool isActive, required VoidCallback onToggle}) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? MountMapColors.teal.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? MountMapColors.teal : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isActive ? MountMapColors.teal : Colors.white54),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: isActive ? MountMapColors.teal : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _chartColorPresetChip({required String name, required Color p, required Color s, required VoidCallback onSelect}) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: p, shape: BoxShape.circle)),
            const SizedBox(width: 2),
            Container(width: 8, height: 8, decoration: BoxDecoration(color: s, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: MountMapColors.teal, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  ({double sum, double avg, double max, double min})? _computeChartStats(List<List<String>> data) {
    if (data.length < 2) return null;
    final doubleValues = <double>[];

    for (int r = 1; r < data.length; r++) {
      for (int c = 0; c < data[r].length; c++) {
        final d = _parseFlexibleNumber(data[r][c]);
        if (d != null) {
          doubleValues.add(d);
        }
      }
    }

    if (doubleValues.isEmpty) return null;

    double sum = doubleValues.reduce((a, b) => a + b);
    double max = doubleValues.reduce((a, b) => a > b ? a : b);
    double min = doubleValues.reduce((a, b) => a < b ? a : b);
    double avg = sum / doubleValues.length;

    return (sum: sum, avg: avg, max: max, min: min);
  }

  void _showAIInsightsModal(MountMapProvider provider, DescriptionBlock block) {
    final data = block.tableData ?? [];
    final stats = _computeChartStats(data);
    final rowCount = data.length > 1 ? data.length - 1 : 0;

    String topCategory = "N/A";
    double topVal = -double.infinity;
    if (data.length > 1) {
      for (int r = 1; r < data.length; r++) {
        if (data[r].length > 1) {
          final v = double.tryParse(data[r][1]) ?? (double.tryParse(data[r].last) ?? 0);
          if (v > topVal) {
            topVal = v;
            topCategory = data[r][0];
          }
        }
      }
    }

    final summary = stats != null
        ? "Berdasarkan analisis data grafik '${block.chartType ?? "Chart"}', terdapat $rowCount item data dengan total nilai ${stats.sum.toStringAsFixed(1)} dan rata-rata ${stats.avg.toStringAsFixed(1)}. Kategori paling unggul/dominan adalah '$topCategory' dengan kontribusi ${topVal % 1 == 0 ? topVal.toInt() : topVal.toStringAsFixed(1)}. Performa grafik menunjukkan tren positif dan berada pada parameter stabil."
        : "Grafik '${block.chartType ?? "Chart"}' berisi $rowCount baris data kualitatif. Struktur hierarki dan aliran data terdistribusi dengan simetris.";

    showModalBottomSheet(
      context: context,
      backgroundColor: provider.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MountMapColors.violet.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.psychology_rounded, color: MountMapColors.violet, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI EXECUTIVE INSIGHTS & FORECAST",
                        style: TextStyle(color: provider.textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                      ),
                      Text(
                        "Analisis Inteligensi Otomatis",
                        style: TextStyle(color: provider.textColor.withValues(alpha: 0.5), fontSize: 10),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: provider.textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MountMapColors.violet.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MountMapColors.violet.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 16, color: MountMapColors.violet),
                      const SizedBox(width: 6),
                      Text("RINGKASAN EKSEKUTIF", style: TextStyle(color: provider.textColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary,
                    style: TextStyle(color: provider.textColor.withValues(alpha: 0.85), fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
            if (stats != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _insightBadge("TOTAL kontribusi", stats.sum.toStringAsFixed(1), MountMapColors.teal),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _insightBadge("TOP PERFORMER", topCategory, MountMapColors.violet),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _insightBadge(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Future<void> _exportEmbeddedChartToPNG(GlobalKey key, String chartName) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/Chart_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles([XFile(file.path)], text: 'MountMap Chart Export: $chartName');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export PNG error: $e')));
    }
  }

  void _openFullscreenChartModal(MountMapProvider provider, DescriptionBlock block) {
    final chartState = _getChartState(block.id);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: provider.cardColor,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fullscreen_rounded, color: MountMapColors.teal),
                        const SizedBox(width: 8),
                        Text(
                          (block.chartType ?? "Chart").toUpperCase(),
                          style: TextStyle(color: provider.textColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: provider.textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: provider.currentTheme == AppThemeMode.dark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: provider.textColor.withValues(alpha: 0.1)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: ChartEnginePainter(
                        chartType: block.chartType ?? 'rose chart',
                        data: NodeModel(id: 'temp', text: '', position: Offset.zero, tableData: block.tableData),
                        primaryColor: chartState['primaryColor'] as Color,
                        secondaryColor: chartState['secondaryColor'] as Color,
                        showStats: chartState['showStats'] as bool,
                        showTrend: chartState['showTrend'] as bool,
                        isDark: provider.currentTheme == AppThemeMode.dark,
                        visualSettings: {
                          'intensity': chartState['intensity'] as double,
                          'thickness': chartState['thickness'] as double,
                          'opacity': chartState['opacity'] as double,
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _chartMiniToggle(
                      label: "Stats Overlay",
                      icon: Icons.analytics_outlined,
                      isActive: chartState['showStats'] as bool,
                      onToggle: () {
                        setDialogState(() => chartState['showStats'] = !(chartState['showStats'] as bool));
                        setState(() {});
                      },
                    ),
                    const SizedBox(width: 12),
                    _chartMiniToggle(
                      label: "Trend Line",
                      icon: Icons.show_chart_rounded,
                      isActive: chartState['showTrend'] as bool,
                      onToggle: () {
                        setDialogState(() => chartState['showTrend'] = !(chartState['showTrend'] as bool));
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChartTypePickerForExistingBlock(MountMapProvider provider, String nodeId, String blockId) {
    final Map<String, List<Map<String, dynamic>>> categories = {
      "FLOW & RELATIONAL": [
        {"name": "Alluvial Diagram", "icon": Icons.waterfall_chart_rounded},
        {"name": "Sankey Diagram", "icon": Icons.subway_rounded},
        {"name": "Chord Diagram", "icon": Icons.donut_large_rounded},
        {"name": "Hyperbolic Tree", "icon": Icons.account_tree_rounded},
      ],
      "COMPARISON & STATS": [
        {"name": "Butterfly Chart", "icon": Icons.compare_arrows_rounded},
        {"name": "Histogram", "icon": Icons.bar_chart_rounded},
        {"name": "Pareto Chart", "icon": Icons.show_chart_rounded},
        {"name": "Radial Bar Chart", "icon": Icons.vignette_rounded},
        {"name": "Rose Chart", "icon": Icons.filter_tilt_shift_rounded},
      ],
      "HIERARCHICAL": [
        {"name": "Treemap", "icon": Icons.grid_view_rounded},
        {"name": "Multi-level Pie Chart", "icon": Icons.pie_chart_rounded},
      ],
      "SCIENTIFIC & DATA": [
        {"name": "Contour Plot", "icon": Icons.waves_rounded},
        {"name": "Taylor Diagram", "icon": Icons.radar_rounded},
        {"name": "Three-dimensional Stream Graph", "icon": Icons.multiline_chart_rounded},
        {"name": "Data Table", "icon": Icons.table_view_rounded},
      ],
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: provider.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("CHANGE CHART TYPE",
                    style: TextStyle(color: provider.textColor.withValues(alpha: 0.5), letterSpacing: 3, fontSize: 10, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: provider.textColor.withValues(alpha: 0.5)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: categories.entries.map((category) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                        child: Row(
                          children: [
                            Container(width: 4, height: 14, decoration: BoxDecoration(color: MountMapColors.teal, borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 10),
                            Text(category.key, style: TextStyle(color: provider.textColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                          ],
                        ),
                      ),
                      GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: category.value.length,
                        itemBuilder: (context, index) {
                          final chart = category.value[index];
                          return InkWell(
                            onTap: () {
                              provider.updateDescriptionBlock(nodeId, blockId, chartType: chart['name']);
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: provider.textColor.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: provider.textColor.withValues(alpha: 0.05)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: MountMapColors.teal.withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(chart['icon'] as IconData, color: MountMapColors.teal, size: 24),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    chart['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: provider.textColor.withValues(alpha: 0.8), fontSize: 9, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(NodeModel node, MountMapProvider provider) {
    if (node.labels.isEmpty) {
      return Text(
        "No tags added",
        style: TextStyle(color: provider.textColor.withValues(alpha: 0.3), fontSize: 12),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: node.labels.map((l) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: MountMapColors.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: MountMapColors.teal.withValues(alpha: 0.2)),
        ),
        child: Text(
          l.toUpperCase(),
          style: const TextStyle(color: MountMapColors.teal, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      )).toList(),
    );
  }

  Widget _buildFooter(MountMapProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: provider.cardColor,
        border: Border(top: BorderSide(color: provider.textColor.withValues(alpha: 0.1))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildActionButton('Add Text', Icons.note_add_rounded, _addTextItem, provider.textColor),
            const SizedBox(width: 8),
            _buildActionButton('Add Attachment', Icons.attach_file_rounded, _addAttachmentItem, provider.textColor),
            const SizedBox(width: 8),
            _buildActionButton('Add Table', Icons.table_chart_rounded, _addTableItem, provider.textColor),
            const SizedBox(width: 8),
            _buildActionButton('Add Chart', Icons.bar_chart_rounded, _addChartItem, provider.textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed, Color textColor) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14, color: MountMapColors.teal),
      label: Text(label, style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.8))),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: MountMapColors.teal.withValues(alpha: 0.2)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _TextBlockEditor extends StatefulWidget {
  final String initialContent;
  final Color textColor;
  final ValueChanged<String> onSave;
  final VoidCallback onCancel;

  const _TextBlockEditor({
    required this.initialContent,
    required this.textColor,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_TextBlockEditor> createState() => _TextBlockEditorState();
}

class _TextBlockEditorState extends State<_TextBlockEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _controller,
          maxLines: null,
          autofocus: true,
          style: TextStyle(color: widget.textColor, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.textColor.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            hintText: "Enter text...",
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(onPressed: widget.onCancel, child: const Text("CANCEL")),
            ElevatedButton(
              onPressed: () => widget.onSave(_controller.text),
              style: ElevatedButton.styleFrom(backgroundColor: MountMapColors.teal, foregroundColor: Colors.white),
              child: const Text("SAVE"),
            ),
          ],
        ),
      ],
    );
  }
}
