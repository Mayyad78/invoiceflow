import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'InvoiceFlow'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @newInvoice.
  ///
  /// In en, this message translates to:
  /// **'New Invoice'**
  String get newInvoice;

  /// No description provided for @newQuote.
  ///
  /// In en, this message translates to:
  /// **'New Quote'**
  String get newQuote;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to InvoiceFlow'**
  String get welcome;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @clientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clientsTitle;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get addClient;

  /// No description provided for @editClient.
  ///
  /// In en, this message translates to:
  /// **'Edit Client'**
  String get editClient;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get clientName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @noClientsYet.
  ///
  /// In en, this message translates to:
  /// **'No clients yet'**
  String get noClientsYet;

  /// No description provided for @clientSaved.
  ///
  /// In en, this message translates to:
  /// **'Client saved successfully'**
  String get clientSaved;

  /// No description provided for @clientUpdated.
  ///
  /// In en, this message translates to:
  /// **'Client updated successfully'**
  String get clientUpdated;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoicesTitle;

  /// No description provided for @createInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// No description provided for @editInvoice.
  ///
  /// In en, this message translates to:
  /// **'Edit Invoice'**
  String get editInvoice;

  /// No description provided for @editQuote.
  ///
  /// In en, this message translates to:
  /// **'Edit Quote'**
  String get editQuote;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get invoiceNumber;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get issueDate;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @selectClient.
  ///
  /// In en, this message translates to:
  /// **'Select Client'**
  String get selectClient;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @taxPercent.
  ///
  /// In en, this message translates to:
  /// **'Tax %'**
  String get taxPercent;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// No description provided for @remainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount'**
  String get remainingAmount;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// No description provided for @statusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get statusPartial;

  /// No description provided for @invoiceSaved.
  ///
  /// In en, this message translates to:
  /// **'Invoice saved successfully'**
  String get invoiceSaved;

  /// No description provided for @invoiceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Document updated successfully'**
  String get invoiceUpdated;

  /// No description provided for @noInvoicesYet.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet'**
  String get noInvoicesYet;

  /// No description provided for @invoiceTypeInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceTypeInvoice;

  /// No description provided for @invoiceTypeQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get invoiceTypeQuote;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @itemDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Item description is required'**
  String get itemDescriptionRequired;

  /// No description provided for @atLeastOneItem.
  ///
  /// In en, this message translates to:
  /// **'Add at least one item'**
  String get atLeastOneItem;

  /// No description provided for @clientRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a client'**
  String get clientRequired;

  /// No description provided for @enterValidPaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid partial paid amount'**
  String get enterValidPaidAmount;

  /// No description provided for @paidAmountCannotExceedTotal.
  ///
  /// In en, this message translates to:
  /// **'Paid amount cannot exceed total'**
  String get paidAmountCannotExceedTotal;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @invoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Invoice Details'**
  String get invoiceDetails;

  /// No description provided for @businessDetails.
  ///
  /// In en, this message translates to:
  /// **'Business Details'**
  String get businessDetails;

  /// No description provided for @invoicePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice Preview'**
  String get invoicePreviewTitle;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @quotePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Quote Preview'**
  String get quotePreviewTitle;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @businessProfile.
  ///
  /// In en, this message translates to:
  /// **'Business Profile'**
  String get businessProfile;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @currencySettings.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencySettings;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully'**
  String get profileSaved;

  /// No description provided for @currencySaved.
  ///
  /// In en, this message translates to:
  /// **'Currency updated successfully'**
  String get currencySaved;

  /// No description provided for @searchClients.
  ///
  /// In en, this message translates to:
  /// **'Search clients'**
  String get searchClients;

  /// No description provided for @searchInvoices.
  ///
  /// In en, this message translates to:
  /// **'Search invoices'**
  String get searchInvoices;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @totalInvoices.
  ///
  /// In en, this message translates to:
  /// **'Total Invoices'**
  String get totalInvoices;

  /// No description provided for @paidInvoices.
  ///
  /// In en, this message translates to:
  /// **'Paid Invoices'**
  String get paidInvoices;

  /// No description provided for @unpaidInvoices.
  ///
  /// In en, this message translates to:
  /// **'Unpaid Invoices'**
  String get unpaidInvoices;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @pendingAmount.
  ///
  /// In en, this message translates to:
  /// **'Pending Amount'**
  String get pendingAmount;

  /// No description provided for @collectedAmount.
  ///
  /// In en, this message translates to:
  /// **'Collected Amount'**
  String get collectedAmount;

  /// No description provided for @outstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Balance'**
  String get outstandingBalance;

  /// No description provided for @totalClients.
  ///
  /// In en, this message translates to:
  /// **'Total Clients'**
  String get totalClients;

  /// No description provided for @totalQuotes.
  ///
  /// In en, this message translates to:
  /// **'Total Quotes'**
  String get totalQuotes;

  /// No description provided for @invoiceStatusBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Invoice Status Breakdown'**
  String get invoiceStatusBreakdown;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteClientMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this client?'**
  String get deleteClientMessage;

  /// No description provided for @deleteInvoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this invoice?'**
  String get deleteInvoiceMessage;

  /// No description provided for @confirmConvertQuote.
  ///
  /// In en, this message translates to:
  /// **'Convert Quote'**
  String get confirmConvertQuote;

  /// No description provided for @confirmConvertQuoteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will create a new invoice from the selected quote and keep the original quote unchanged.'**
  String get confirmConvertQuoteMessage;

  /// No description provided for @convertToInvoice.
  ///
  /// In en, this message translates to:
  /// **'Convert to Invoice'**
  String get convertToInvoice;

  /// No description provided for @quoteConverted.
  ///
  /// In en, this message translates to:
  /// **'Quote converted to invoice successfully'**
  String get quoteConverted;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @startByAddingClient.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first client.'**
  String get startByAddingClient;

  /// No description provided for @startByCreatingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Start by creating your first invoice.'**
  String get startByCreatingInvoice;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @billTo.
  ///
  /// In en, this message translates to:
  /// **'Bill To'**
  String get billTo;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your business'**
  String get thankYou;

  /// No description provided for @generatedBy.
  ///
  /// In en, this message translates to:
  /// **'Generated by InvoiceFlow'**
  String get generatedBy;

  /// No description provided for @documentNumbering.
  ///
  /// In en, this message translates to:
  /// **'Document numbering'**
  String get documentNumbering;

  /// No description provided for @invoicePrefix.
  ///
  /// In en, this message translates to:
  /// **'Invoice prefix'**
  String get invoicePrefix;

  /// No description provided for @quotePrefix.
  ///
  /// In en, this message translates to:
  /// **'Quote prefix'**
  String get quotePrefix;

  /// No description provided for @nextInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Next invoice number'**
  String get nextInvoiceNumber;

  /// No description provided for @nextQuoteNumber.
  ///
  /// In en, this message translates to:
  /// **'Next quote number'**
  String get nextQuoteNumber;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @saveNumberingSettings.
  ///
  /// In en, this message translates to:
  /// **'Save numbering settings'**
  String get saveNumberingSettings;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'Export your local app data to a JSON backup file, or restore a previous backup. Restore will fully replace current local data.'**
  String get backupDescription;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreBackupWarning.
  ///
  /// In en, this message translates to:
  /// **'Restoring a backup will replace current clients, invoices, settings, and business profile on this device. This cannot be undone.'**
  String get restoreBackupWarning;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported successfully'**
  String get backupExported;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully'**
  String get backupRestored;

  /// No description provided for @clientDetails.
  ///
  /// In en, this message translates to:
  /// **'Client Details'**
  String get clientDetails;

  /// No description provided for @clientSummary.
  ///
  /// In en, this message translates to:
  /// **'Client Summary'**
  String get clientSummary;

  /// No description provided for @clientHistory.
  ///
  /// In en, this message translates to:
  /// **'Client History'**
  String get clientHistory;

  /// No description provided for @totalDocuments.
  ///
  /// In en, this message translates to:
  /// **'Total Documents'**
  String get totalDocuments;

  /// No description provided for @noClientDocuments.
  ///
  /// In en, this message translates to:
  /// **'No invoices or quotes found for this client yet.'**
  String get noClientDocuments;

  /// No description provided for @tapToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap to view details'**
  String get tapToViewDetails;

  /// No description provided for @quoteAlreadyConverted.
  ///
  /// In en, this message translates to:
  /// **'This quote has already been converted to an invoice'**
  String get quoteAlreadyConverted;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// No description provided for @template.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get template;

  /// No description provided for @saveAsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as Template'**
  String get saveAsTemplate;

  /// No description provided for @templateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved successfully'**
  String get templateSaved;

  /// No description provided for @useTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use Template'**
  String get useTemplate;

  /// No description provided for @noTemplatesYet.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get noTemplatesYet;

  /// No description provided for @invoiceTemplates.
  ///
  /// In en, this message translates to:
  /// **'Invoice Templates'**
  String get invoiceTemplates;

  /// No description provided for @quoteTemplates.
  ///
  /// In en, this message translates to:
  /// **'Quote Templates'**
  String get quoteTemplates;

  /// No description provided for @renameTemplate.
  ///
  /// In en, this message translates to:
  /// **'Rename Template'**
  String get renameTemplate;

  /// No description provided for @editTemplate.
  ///
  /// In en, this message translates to:
  /// **'Edit Template'**
  String get editTemplate;

  /// No description provided for @templateUpdated.
  ///
  /// In en, this message translates to:
  /// **'Template updated successfully'**
  String get templateUpdated;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get templateName;

  /// No description provided for @deleteTemplateMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this template?'**
  String get deleteTemplateMessage;

  /// No description provided for @startByCreatingInvoiceTemplate.
  ///
  /// In en, this message translates to:
  /// **'Start by saving an invoice as a template.'**
  String get startByCreatingInvoiceTemplate;

  /// No description provided for @startByCreatingQuoteTemplate.
  ///
  /// In en, this message translates to:
  /// **'Start by saving a quote as a template.'**
  String get startByCreatingQuoteTemplate;

  /// No description provided for @searchTemplates.
  ///
  /// In en, this message translates to:
  /// **'Search templates'**
  String get searchTemplates;

  /// No description provided for @favoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get favoritesOnly;

  /// No description provided for @noTemplatesFound.
  ///
  /// In en, this message translates to:
  /// **'No templates found'**
  String get noTemplatesFound;

  /// No description provided for @tryDifferentSearchOrFilter.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or turn off the favorites filter.'**
  String get tryDifferentSearchOrFilter;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
