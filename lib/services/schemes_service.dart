import '../models/scheme_model.dart';

class SchemesService {
  static final List<GovernmentScheme> schemes = [
    GovernmentScheme(
      id: 'PMKISAN',
      title: 'PM-KISAN',
      description: 'Direct income support of ₹6000 per year to farmer families',
      imagePath: 'assets/images/PM-KISAN.png', // Match exact filename
      url: 'https://pmkisan.gov.in/',
    ),
    GovernmentScheme(
      id: 'KCC',
      title: 'Kisan Credit Card',
      description: 'Easy credit access for farmers',
      imagePath: 'assets/images/KCC.png',
      url: 'https://www.pib.gov.in/FactsheetDetails.aspx?Id=148600',
    ),
    GovernmentScheme(
      id: 'PMFBY',
      title: 'Pradhan Mantri Fasal Bima Yojana',
      description: 'Crop insurance scheme to protect against crop failure',
      imagePath: 'assets/images/PMFBY.png',
      url: 'https://pmfby.gov.in/',
    ),
    GovernmentScheme(
      id: 'SHCS',
      title: 'Soil Health Card Scheme',
      description: 'Provides soil health assessment and recommendations',
      imagePath: 'assets/images/SHCS.png',
      url: 'https://www.soilhealth.dac.gov.in/',
    ),
    GovernmentScheme(
      id: 'PKVY',
      title: 'Paramparagat Krishi Vikas Yojana',
      description: 'Promotes organic farming practices',
      imagePath: 'assets/images/PKVY.png',
      url: 'https://darpg.gov.in/',
    ),
    GovernmentScheme(
      id: 'eNAM',
      title: 'National Agriculture Market',
      description: 'Online trading platform for agricultural commodities',
      imagePath: 'assets/images/eNAM.png',
      url: 'https://www.enam.gov.in/',
    ),
    GovernmentScheme(
      id: 'RKVY',
      title: 'Rashtriya Krishi Vikas Yojana',
      description: 'Ensures holistic development of agriculture',
      imagePath: 'assets/images/RKVY.png',
      url: 'https://rkvy.da.gov.in/',
    ),
    GovernmentScheme(
      id: 'GBY',
      title: 'Gramin Bhandaran Yojana',
      description: 'Creation of scientific storage capacity',
      imagePath: 'assets/images/GBY.png',
      url: 'https://dmi.gov.in/',
    ),
    GovernmentScheme(
      id: 'AIF',
      title: 'Agriculture Infrastructure Fund',
      description: 'Financing facility for agriculture infrastructure projects',
      imagePath: 'assets/images/AIF.png',
      url: 'https://agriinfra.dac.gov.in/',
    ),
    GovernmentScheme(
      id: 'MSUK',
      title: 'Magalir Suya Udhavi Kulu',
      description: 'Women self-help groups for rural development',
      imagePath: 'assets/images/MSUK.png',
      url: 'https://www.tncdw.org/pages/view/Mahalir-Thittam',
    ),
  ];

  static List<GovernmentScheme> getAllSchemes() => schemes;
  
  static GovernmentScheme? getSchemeById(String id) {
    try {
      return schemes.firstWhere((scheme) => scheme.id == id);
    } catch (_) {
      return null;
    }
  }
}
