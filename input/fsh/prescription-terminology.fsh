// ---------------------------------------------------------------------------
// Terminology and identifier systems for the Bonolo prescription workflow.
// STATUS: DRAFT. This describes an agreed design (2026-11-23) that is NOT yet
// implemented. Concept UUIDs and names come from the eRegister concept
// dictionary release of 2026-11-06. The http://health.gov.ls/fhir/... URLs are
// proposed and must be confirmed by the Lesotho MoH before go-live.
// ---------------------------------------------------------------------------

CodeSystem: EregisterConcept
Id: eregister-concept
Title: "eRegister OpenMRS concepts (fragment)"
Description: """
OpenMRS concepts of the Lesotho eRegister concept dictionary, identified by their concept **UUID**. FHIR2 emits these
UUIDs as codings **without a system**; the prescription push adds this system so that ValueSets and profiles can bind to
them. This fragment lists only the concepts the Bonolo prescription workflow uses: the *Bonolo Health* questions and
their answers, and the regimen used in the example. Displays are the concepts' English names.
"""
* ^url = $eregister-concept
* ^status = #draft
* ^publisher = "Lesotho eRegister Team"
* ^content = #fragment
* ^experimental = false
* ^caseSensitive = false
* #c8866aaf-4626-4d86-8667-d21e906d0b6e "Bonolo Health Client" "Question (coded Yes/No). Only prescriptions for patients answered Yes are sent."
* #a2065636-5326-40f5-aed6-0cc2cca81ccc "Yes" "Answer to Bonolo Health Client."
* #b497171e-0410-4d8d-bbd4-7e1a8f8b504e "No" "Answer to Bonolo Health Client."
* #13382e01-9f18-488b-b2d2-58ab54c82d82 "HIVTC, ART Regimen" "Question (coded). The patient's current ART regimen; its answers are the regimen concepts."
* #9f2696bd-9c81-4ee8-9844-e6c77cd19e03 "HIVTC, Bonolo Health next collection date" "Question (date). Next drug pickup date."
* #c128a7a7-45e9-4313-a49a-75b67b060456 "Pick-up Locker Type" "Question (coded). Pickup type."
* #59b6f57b-770c-4168-9a79-f910dd6cb19f "E-locker" "Pickup type."
* #31fef719-4519-4e20-8fc4-37012d90a2e8 "Retail Pharmacy" "Pickup type."
* #3f2d9548-49a1-4f63-80e2-7e072966e97f "Outreach_Health_Post" "Pickup type."
* #79186178-1fed-4645-9d12-bfac0956ac56 "Pick-up District" "Question (coded). Pickup district."
* #44179144-9a35-4fd7-92f5-de9d5801ac7b "Pick-up District Mohales Hoek" "Pickup district."
* #3c26267d-e290-4006-ad56-f0de1a5518df "Pick-up District Mafeteng" "Pickup district."
* #bd84b856-7699-49d9-a8cf-baad451d54d1 "Pick-up District Maseru" "Pickup district."
* #cfee8964-e9b0-4a09-8ad7-fb48bd643a46 "E-locker Pickup Location Maseru" "Question (coded). Its answer is the specific pickup site."
* #f1e0d69f-130e-41c3-8523-478ed5d889bb "E-locker Pickup Location Mafeteng" "Question (coded). Its answer is the specific pickup site."
* #2c3e0e68-4756-48a8-9fb4-6c1a61fd2f1a "E-locker Pickup Location Mohales Hoek" "Question (coded). Its answer is the specific pickup site."
* #636f1d68-cd13-47e9-a5d1-44d54b53e88d "Retail Pharmacy Pickup location Maseru" "Question (coded). Its answer is the specific pickup site."
* #96d64908-3423-4c3b-b8a1-c57fac8968bd "Retail Pharmacy Pickup location Mafeteng" "Question (coded). Its answer is the specific pickup site."
* #87377aaa-f52a-45fb-90c5-2c3788cc440a "Retail Pharmacy Pickup location Mohales Hoek" "Question (coded). Its answer is the specific pickup site."
* #1100ca2c-b9d1-4b94-9a9e-ece592c3cd3e "Outreach/Health Post Pickup location Maseru" "Question (coded). Its answer is the specific pickup site."
* #f9d5dadf-1d49-4d75-b9e0-820c2ccce34c "Outreach/Health Post Pickup location Mafeteng" "Question (coded). No answers are defined yet; see the Prescription Workflow page."
* #d65b1f46-244a-4ac0-9614-567119bf01c5 "Outreach/Health Post Pickup location Mohales Hoek" "Question (coded). No answers are defined yet; see the Prescription Workflow page."
* #e86226ce-b4ba-42e1-b2d4-28e4a1922268 "Baylor COE" "Pickup site. Answer to E-locker Pickup Location Maseru."
* #496117d1-f42e-473d-9e1e-d185758ba3c5 "Domicilliary HC, Maseru" "Pickup site. Answer to E-locker Pickup Location Maseru."
* #2d8c809e-d85f-49e1-a44a-b1f816433706 "Likotsi Filter Clinic, Maseru" "Pickup site. Answer to E-locker Pickup Location Maseru."
* #f5c2b6d8-6f1c-43f9-adc9-3cc1066fa9ee "Maseru District Hospital" "Pickup site. Answer to E-locker Pickup Location Maseru."
* #e7bf3d40-3b35-464c-bac4-1f0d33401fb7 "Maseru Mall" "Pickup site. Answer to E-locker Pickup Location Maseru."
* #bb5da546-0b09-4377-8f8b-d8c7e95ad4b2 "Matsieng HC, Maseru" "Pickup site. Answer to E-locker Pickup Location Maseru."
* #c8fe4050-ae87-44c5-ab1a-0d9badbb6b7c "Nazareth HC, Maseru" "Pickup site. Answer to E-locker Pickup Location Maseru."
* #bb21afd5-ebba-4efb-b3e1-bd61e8c90c6f "Pioneer Mall" "Pickup site. Answer to E-locker Pickup Location Maseru."
* #93db9b3e-4ba5-4fda-a0fe-80e39730517f "Qoaling Filter Clinic, Maseru" "Pickup site. Answer to E-locker Pickup Location Maseru."
* #a00526c8-f613-40a5-9fcd-7a419433ddf1 "Senkatana Clinic, Maseru" "Pickup site. Answer to E-locker Pickup Location Maseru."
* #6a07745c-809b-49e3-87cd-23078cefbaa1 "St Josephs HOSP, Maseru" "Pickup site. Answer to E-locker Pickup Location Maseru."
* #02d214e8-d89a-4870-9829-edf89e768518 "Mafeteng HOSP, Mafeteng" "Pickup site. Answer to E-locker Pickup Location Mafeteng."
* #7b0c5af0-f54c-41fb-b64d-7bfb83a8cf67 "Thabana-Morena HC, Mafeteng" "Pickup site. Answer to E-locker Pickup Location Mafeteng."
* #f816e0a9-840b-46f7-9f3a-cbcc0fabe741 "Holy Cross HC, Mohale's Hoek" "Pickup site. Answer to E-locker Pickup Location Mohales Hoek."
* #d16d0db0-49ac-4c40-8e0d-24b1b053c552 "Ntsekhe HOSP, Mohale's Hoek" "Pickup site. Answer to E-locker Pickup Location Mohales Hoek."
* #3eb91f5e-1b62-4e5e-bb8a-5e6643d13d01 "Animan Pharmacy (Khubetsoana)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #a61d9d3b-6688-4839-8003-6494b94d689c "Best Care Pharmacy ( Leqele)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #e26bcb66-8122-40c7-95f6-d6d9aa0d0b09 "Dial for Life Pharmacy (Lithoteng)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #8668e925-c899-4c41-ba11-a19d3c280688 "Ether Pharmacy (Kingsway)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #fc769696-eff3-44f1-adaa-f55d16e1ebe2 "Exceed Pharmacy (Roma)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #a4188f73-6e1a-4de6-8c7f-b6646311c557 "Family Health Pharmacy (Thetsane)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #c1c4807e-7f57-4626-be14-27f3f87a8201 "Grace Pharmacy (Morija)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #301d2453-0454-4c6e-be3b-22f72ebae0d4 "Husteds (Kingsway)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #b226c1e5-df4c-4e13-86af-396b69c3e325 "Husteds (LNDC)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #a538b2c5-71d8-4d30-aeef-ec6be26aa9ba "Kayalethu Pharmacy (Tsolo)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #d4703549-7c61-4337-b9c3-8c19f4fd4c04 "Machache (Naleli)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #7733549a-0550-4e8d-914e-ff5bc595d2f6 "Machache (Nazareth)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #2817d302-e249-49ca-bc4e-6d2d09f2c6c2 "Mago Enterprise (Khubetsoana)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #f9ed2937-4cf6-4edb-b4a3-05de8eaec636 "Maletsunyane Pharmacy (Qoaling)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #e47eb1eb-8333-41c9-a18e-3606cd9ec2be "Medic Discount Pharmacy (Roma)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #c290b3fe-36af-40b7-89ba-b80aa443fd48 "Medic Health Care (Naleli)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #be17e363-4093-4708-854f-e75955f5cb44 "Medicos Pharmacy (Ha Tsolo)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #2150a097-2e89-4326-becf-05ad2d69d2cc "Pholohong Pharmacy (Ha Abia)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #942d0255-bfc0-4d96-b9b7-547c21233365 "QualiPro (Lekhaloaneng)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #3dd0ec4e-71d5-44cd-a47f-70a7c46aa20a "QualiPro (Nelese)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #fc32d760-b318-47f4-bfe5-f051a85f770a "S&T Pharmacy (Sefika)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #d44bb8dc-d2bd-480e-af18-72ed11e687b2 "Total Care Pharmacy (Victoria)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #500200b9-5228-48bd-aba6-d667bd17e338 "Total Care Pharmacy (Thetsane)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #e26aaa66-11d3-4d54-a929-f4cce4d68c23 "Wamma Pharmacy (Matala)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #81a5ff15-3f4a-4a83-9001-8da30daa6083 "Wamma Pharmacy (Pitso Ground)" "Pickup site. Answer to Retail Pharmacy Pickup location Maseru."
* #facef208-c987-4b59-90b0-30b11f177ec1 "Capricon Pharmacy (Town)" "Pickup site. Answer to Retail Pharmacy Pickup location Mafeteng."
* #a0432812-da5e-4517-b846-2a66561f914e "Rite Care Pharmacy( Motsekuoa)" "Pickup site. Answer to Retail Pharmacy Pickup location Mafeteng."
* #91dc8987-8d74-4335-9e8c-f033adc4030c "Theo Pharmaceuticals" "Pickup site. Answer to Retail Pharmacy Pickup location Mafeteng."
* #9d0f5ffe-801b-4491-86c7-b19edfd97a0b "Bakoena Pharmacy (Town)" "Pickup site. Answer to Retail Pharmacy Pickup location Mohales Hoek."
* #7ac998a6-9f1f-4103-959a-0e6b474ca599 "Bophelong Medicare Pharmacy (Town)" "Pickup site. Answer to Retail Pharmacy Pickup location Mohales Hoek."
* #357d64d3-2965-47b3-b2d6-755a4933cf87 "Medical Healthcare (Town)" "Pickup site. Answer to Retail Pharmacy Pickup location Mohales Hoek."
* #6db5b76f-1a07-4e3e-8c1f-005271112344 "Pharma Best Pharmacy (Town)" "Pickup site. Answer to Retail Pharmacy Pickup location Mohales Hoek."
* #e2a40771-ee31-4b0c-82a6-937d083ef5e7 "Health Post, Ha Elia" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #77ccc6bb-3470-498f-b78c-0569474a99cf "Health Post, Ha Monyooe" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #f45ddf3f-fb7a-4a5a-9165-55642345bd13 "Health Post, Ha Sehlahla" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #60514f7f-90c9-453a-8665-57395216b2d7 "Health Post, Ha Tsilo" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #41071b79-385b-47d2-9f3c-8c39a73b18d5 "Health Post, Lethena" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #cf01ca74-76af-4783-86ba-608a41195002 "Health Post, Maama" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #c61ccdfa-60f6-4421-8868-d95461bc9f35 "Health Post, Makoetje" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #0fd97272-cb55-41a1-986a-341cfbd5c0aa "Health Post, Makotoko" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #2c12dcc0-717d-4992-b459-2c1f45e6e7f5 "Health Post, Masupha" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #0aaa62d6-945a-4466-8479-92a9e2f0cfbc "Health Post, Mohalenyane" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #caade247-d1b1-4e12-982e-73a982c9e904 "Health Post, Mpiti" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #82ded733-bd9b-4c27-903c-9f004c3418cf "Health Post, Nqheku" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #a2014262-bdc2-4707-a070-85249f18ed8a "Health Post, Nyakosoba" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #d683b840-9cf4-407e-b26a-d732b5181a5c "Health Post,Pae-la-ithlatsoa" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #5f53c88a-4e72-48bb-bb94-9977b71e77a3 "Health Post, Ramotsoane" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #b27b4ae3-309b-48bb-b136-e00840aa2d48 "Health Post, Ratau" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #d0be639d-2733-464d-a163-e0fb1f03d642 "Health Post, Setibing" "Pickup site. Answer to Outreach/Health Post Pickup location Maseru."
* #225b0d93-d4b9-46b0-bbb2-1bce82c9107c "1j=TDF-3TC-DTG" "ART regimen (answer to HIVTC, ART Regimen). Used in the example."

ValueSet: BonoloPickupQuestions
Id: bonolo-pickup-questions
Title: "Bonolo pickup-point questions"
Description: """
The nine questions of the *Bonolo Health* form section that record where a patient collects medication. Which question
was answered gives the **pickup type and district** (e.g. *E-locker Pickup Location Maseru*); the answer gives the
**site**. Used as `Observation.code` in [Bonolo Pickup Point Observation](StructureDefinition-bonolo-pickup-point-observation.html).
*Outreach/Health Post Pickup location Mafeteng* and *… Mohales Hoek* have no answers in the dictionary yet.
"""
* ^status = #draft
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* $eregister-concept#cfee8964-e9b0-4a09-8ad7-fb48bd643a46 "E-locker Pickup Location Maseru"
* $eregister-concept#f1e0d69f-130e-41c3-8523-478ed5d889bb "E-locker Pickup Location Mafeteng"
* $eregister-concept#2c3e0e68-4756-48a8-9fb4-6c1a61fd2f1a "E-locker Pickup Location Mohales Hoek"
* $eregister-concept#636f1d68-cd13-47e9-a5d1-44d54b53e88d "Retail Pharmacy Pickup location Maseru"
* $eregister-concept#96d64908-3423-4c3b-b8a1-c57fac8968bd "Retail Pharmacy Pickup location Mafeteng"
* $eregister-concept#87377aaa-f52a-45fb-90c5-2c3788cc440a "Retail Pharmacy Pickup location Mohales Hoek"
* $eregister-concept#1100ca2c-b9d1-4b94-9a9e-ece592c3cd3e "Outreach/Health Post Pickup location Maseru"
* $eregister-concept#f9d5dadf-1d49-4d75-b9e0-820c2ccce34c "Outreach/Health Post Pickup location Mafeteng"
* $eregister-concept#d65b1f46-244a-4ac0-9614-567119bf01c5 "Outreach/Health Post Pickup location Mohales Hoek"

ValueSet: BonoloPickupSites
Id: bonolo-pickup-sites
Title: "Bonolo pickup sites"
Description: "Every answer of the nine pickup-point questions (concept dictionary 2026-11-06): e-locker sites, retail pharmacies and outreach health posts."
* ^status = #draft
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* $eregister-concept#e86226ce-b4ba-42e1-b2d4-28e4a1922268 "Baylor COE"
* $eregister-concept#496117d1-f42e-473d-9e1e-d185758ba3c5 "Domicilliary HC, Maseru"
* $eregister-concept#2d8c809e-d85f-49e1-a44a-b1f816433706 "Likotsi Filter Clinic, Maseru"
* $eregister-concept#f5c2b6d8-6f1c-43f9-adc9-3cc1066fa9ee "Maseru District Hospital"
* $eregister-concept#e7bf3d40-3b35-464c-bac4-1f0d33401fb7 "Maseru Mall"
* $eregister-concept#bb5da546-0b09-4377-8f8b-d8c7e95ad4b2 "Matsieng HC, Maseru"
* $eregister-concept#c8fe4050-ae87-44c5-ab1a-0d9badbb6b7c "Nazareth HC, Maseru"
* $eregister-concept#bb21afd5-ebba-4efb-b3e1-bd61e8c90c6f "Pioneer Mall"
* $eregister-concept#93db9b3e-4ba5-4fda-a0fe-80e39730517f "Qoaling Filter Clinic, Maseru"
* $eregister-concept#a00526c8-f613-40a5-9fcd-7a419433ddf1 "Senkatana Clinic, Maseru"
* $eregister-concept#6a07745c-809b-49e3-87cd-23078cefbaa1 "St Josephs HOSP, Maseru"
* $eregister-concept#02d214e8-d89a-4870-9829-edf89e768518 "Mafeteng HOSP, Mafeteng"
* $eregister-concept#7b0c5af0-f54c-41fb-b64d-7bfb83a8cf67 "Thabana-Morena HC, Mafeteng"
* $eregister-concept#f816e0a9-840b-46f7-9f3a-cbcc0fabe741 "Holy Cross HC, Mohale's Hoek"
* $eregister-concept#d16d0db0-49ac-4c40-8e0d-24b1b053c552 "Ntsekhe HOSP, Mohale's Hoek"
* $eregister-concept#3eb91f5e-1b62-4e5e-bb8a-5e6643d13d01 "Animan Pharmacy (Khubetsoana)"
* $eregister-concept#a61d9d3b-6688-4839-8003-6494b94d689c "Best Care Pharmacy ( Leqele)"
* $eregister-concept#e26bcb66-8122-40c7-95f6-d6d9aa0d0b09 "Dial for Life Pharmacy (Lithoteng)"
* $eregister-concept#8668e925-c899-4c41-ba11-a19d3c280688 "Ether Pharmacy (Kingsway)"
* $eregister-concept#fc769696-eff3-44f1-adaa-f55d16e1ebe2 "Exceed Pharmacy (Roma)"
* $eregister-concept#a4188f73-6e1a-4de6-8c7f-b6646311c557 "Family Health Pharmacy (Thetsane)"
* $eregister-concept#c1c4807e-7f57-4626-be14-27f3f87a8201 "Grace Pharmacy (Morija)"
* $eregister-concept#301d2453-0454-4c6e-be3b-22f72ebae0d4 "Husteds (Kingsway)"
* $eregister-concept#b226c1e5-df4c-4e13-86af-396b69c3e325 "Husteds (LNDC)"
* $eregister-concept#a538b2c5-71d8-4d30-aeef-ec6be26aa9ba "Kayalethu Pharmacy (Tsolo)"
* $eregister-concept#d4703549-7c61-4337-b9c3-8c19f4fd4c04 "Machache (Naleli)"
* $eregister-concept#7733549a-0550-4e8d-914e-ff5bc595d2f6 "Machache (Nazareth)"
* $eregister-concept#2817d302-e249-49ca-bc4e-6d2d09f2c6c2 "Mago Enterprise (Khubetsoana)"
* $eregister-concept#f9ed2937-4cf6-4edb-b4a3-05de8eaec636 "Maletsunyane Pharmacy (Qoaling)"
* $eregister-concept#e47eb1eb-8333-41c9-a18e-3606cd9ec2be "Medic Discount Pharmacy (Roma)"
* $eregister-concept#c290b3fe-36af-40b7-89ba-b80aa443fd48 "Medic Health Care (Naleli)"
* $eregister-concept#be17e363-4093-4708-854f-e75955f5cb44 "Medicos Pharmacy (Ha Tsolo)"
* $eregister-concept#2150a097-2e89-4326-becf-05ad2d69d2cc "Pholohong Pharmacy (Ha Abia)"
* $eregister-concept#942d0255-bfc0-4d96-b9b7-547c21233365 "QualiPro (Lekhaloaneng)"
* $eregister-concept#3dd0ec4e-71d5-44cd-a47f-70a7c46aa20a "QualiPro (Nelese)"
* $eregister-concept#fc32d760-b318-47f4-bfe5-f051a85f770a "S&T Pharmacy (Sefika)"
* $eregister-concept#d44bb8dc-d2bd-480e-af18-72ed11e687b2 "Total Care Pharmacy (Victoria)"
* $eregister-concept#500200b9-5228-48bd-aba6-d667bd17e338 "Total Care Pharmacy (Thetsane)"
* $eregister-concept#e26aaa66-11d3-4d54-a929-f4cce4d68c23 "Wamma Pharmacy (Matala)"
* $eregister-concept#81a5ff15-3f4a-4a83-9001-8da30daa6083 "Wamma Pharmacy (Pitso Ground)"
* $eregister-concept#facef208-c987-4b59-90b0-30b11f177ec1 "Capricon Pharmacy (Town)"
* $eregister-concept#a0432812-da5e-4517-b846-2a66561f914e "Rite Care Pharmacy( Motsekuoa)"
* $eregister-concept#91dc8987-8d74-4335-9e8c-f033adc4030c "Theo Pharmaceuticals"
* $eregister-concept#9d0f5ffe-801b-4491-86c7-b19edfd97a0b "Bakoena Pharmacy (Town)"
* $eregister-concept#7ac998a6-9f1f-4103-959a-0e6b474ca599 "Bophelong Medicare Pharmacy (Town)"
* $eregister-concept#357d64d3-2965-47b3-b2d6-755a4933cf87 "Medical Healthcare (Town)"
* $eregister-concept#6db5b76f-1a07-4e3e-8c1f-005271112344 "Pharma Best Pharmacy (Town)"
* $eregister-concept#e2a40771-ee31-4b0c-82a6-937d083ef5e7 "Health Post, Ha Elia"
* $eregister-concept#77ccc6bb-3470-498f-b78c-0569474a99cf "Health Post, Ha Monyooe"
* $eregister-concept#f45ddf3f-fb7a-4a5a-9165-55642345bd13 "Health Post, Ha Sehlahla"
* $eregister-concept#60514f7f-90c9-453a-8665-57395216b2d7 "Health Post, Ha Tsilo"
* $eregister-concept#41071b79-385b-47d2-9f3c-8c39a73b18d5 "Health Post, Lethena"
* $eregister-concept#cf01ca74-76af-4783-86ba-608a41195002 "Health Post, Maama"
* $eregister-concept#c61ccdfa-60f6-4421-8868-d95461bc9f35 "Health Post, Makoetje"
* $eregister-concept#0fd97272-cb55-41a1-986a-341cfbd5c0aa "Health Post, Makotoko"
* $eregister-concept#2c12dcc0-717d-4992-b459-2c1f45e6e7f5 "Health Post, Masupha"
* $eregister-concept#0aaa62d6-945a-4466-8479-92a9e2f0cfbc "Health Post, Mohalenyane"
* $eregister-concept#caade247-d1b1-4e12-982e-73a982c9e904 "Health Post, Mpiti"
* $eregister-concept#82ded733-bd9b-4c27-903c-9f004c3418cf "Health Post, Nqheku"
* $eregister-concept#a2014262-bdc2-4707-a070-85249f18ed8a "Health Post, Nyakosoba"
* $eregister-concept#d683b840-9cf4-407e-b26a-d732b5181a5c "Health Post,Pae-la-ithlatsoa"
* $eregister-concept#5f53c88a-4e72-48bb-bb94-9977b71e77a3 "Health Post, Ramotsoane"
* $eregister-concept#b27b4ae3-309b-48bb-b136-e00840aa2d48 "Health Post, Ratau"
* $eregister-concept#d0be639d-2733-464d-a163-e0fb1f03d642 "Health Post, Setibing"

ValueSet: BonoloPickupTypes
Id: bonolo-pickup-types
Title: "Bonolo pickup types"
Description: "Answers of *Pick-up Locker Type*."
* ^status = #draft
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* $eregister-concept#59b6f57b-770c-4168-9a79-f910dd6cb19f "E-locker"
* $eregister-concept#31fef719-4519-4e20-8fc4-37012d90a2e8 "Retail Pharmacy"
* $eregister-concept#3f2d9548-49a1-4f63-80e2-7e072966e97f "Outreach_Health_Post"

ValueSet: BonoloPickupDistricts
Id: bonolo-pickup-districts
Title: "Bonolo pickup districts"
Description: "Answers of *Pick-up District*."
* ^status = #draft
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* $eregister-concept#44179144-9a35-4fd7-92f5-de9d5801ac7b "Pick-up District Mohales Hoek"
* $eregister-concept#3c26267d-e290-4006-ad56-f0de1a5518df "Pick-up District Mafeteng"
* $eregister-concept#bd84b856-7699-49d9-a8cf-baad451d54d1 "Pick-up District Maseru"

// --- Identifier systems ------------------------------------------------------

RuleSet: DraftNamingSystem(name, url, desc)
* name = "{name}"
* description = "{desc}"
* status = #draft
* kind = #identifier
* date = "2026-11-23"
* publisher = "Lesotho eRegister Team"
* uniqueId[0].type = #uri
* uniqueId[0].value = "{url}"
* uniqueId[0].preferred = true

Instance: ls-patient-identifier
InstanceOf: NamingSystem
Usage: #definition
Title: "Bahmni Patient Identifier"
Description: "The Bahmni primary patient ID (identifier type *Patient Identifier*, 81433852-3f10-11e4-adec-0800271c1b75, required, prefix e.g. B1011). Mapped in fhir_patient_identifier_system and set as labonfhir.openmrsPatientIdentifier.uuid / labonfhir.lisIdentifierSystem.url."
* insert DraftNamingSystem(LSPatientIdentifier, http://health.gov.ls/fhir/identifier/patient-identifier, The Bahmni primary patient ID [identifier type Patient Identifier].)

Instance: ls-national-id
InstanceOf: NamingSystem
Usage: #definition
Title: "Lesotho National ID"
Description: "Identifier type *National ID* (0d2ac572-8de3-46c8-9976-1f78899c599f), 12 digits, optional."
* insert DraftNamingSystem(LSNationalId, http://health.gov.ls/fhir/identifier/national-id, Lesotho National ID [identifier type National ID].)

Instance: ls-hiv-program-id
InstanceOf: NamingSystem
Usage: #definition
Title: "HIV Program ID"
Description: "Identifier type *HIV Program ID* (5c1e8ae2-33c6-11e8-8236-0242ac110002)."
* insert DraftNamingSystem(LSHivProgramId, http://health.gov.ls/fhir/identifier/hiv-program-id, HIV Program ID [identifier type HIV Program ID].)

Instance: ls-new-hiv-program-id
InstanceOf: NamingSystem
Usage: #definition
Title: "New HIV Program ID"
Description: "Identifier type *New HIV Program ID* (d778362c-9d6a-4f97-bb5d-e3ea89580742), used at stage 2 sites. Receivers prefer it over HIV Program ID when both are present."
* insert DraftNamingSystem(LSNewHivProgramId, http://health.gov.ls/fhir/identifier/new-hiv-program-id, New HIV Program ID [identifier type New HIV Program ID]. Preferred over HIV Program ID.)

Instance: ls-prescription-number
InstanceOf: NamingSystem
Usage: #definition
Title: "Prescription number"
Description: "MedicationRequest.groupIdentifier: the UUID of the OpenMRS encounter in which the drug orders were written. Every drug line of one prescription carries the same value."
* insert DraftNamingSystem(LSPrescriptionNumber, http://health.gov.ls/fhir/identifier/prescription, Prescription number [the OpenMRS encounter UUID shared by all drug lines].)

Instance: ls-order-number
InstanceOf: NamingSystem
Usage: #definition
Title: "OpenMRS order number"
Description: "MedicationRequest.identifier: the OpenMRS order number of one drug line (e.g. ORD-1234), as shown in Bahmni."
* insert DraftNamingSystem(LSOrderNumber, http://health.gov.ls/fhir/identifier/order-number, OpenMRS order number of one drug line.)

Instance: ls-facility-code
InstanceOf: NamingSystem
Usage: #definition
Title: "Facility code"
Description: "Location.identifier of the originating facility: the value of the location attribute *IdentifierSourceName* (type c1e403a0-3f10-11e4-adec-0800271c1b75) on the encounter location's parent location."
* insert DraftNamingSystem(LSFacilityCode, http://health.gov.ls/fhir/identifier/facility-code, Facility code [location attribute IdentifierSourceName of the parent location].)
