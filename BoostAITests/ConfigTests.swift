//
//  ConfigTests.swift
//  BoostAITests
//
//  Copyright © 2021 boost.ai
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
//  Please contact us at contact@boost.ai if you have any questions.
//

import XCTest
@testable import BoostAI

let str = """
{"linkBelowBackground":"#552a55","spacingBottom":0,"primaryColor":"#552a55","serverMessageColor":"#363636","linkDisplayStyle":"below","contrastColor":"#ffffff","clientMessageBackground":"#ede5ed","fileUploadServiceEndpointUrl":"","hasFilterSelector":false,"serverMessageBackground":"#f2f2f2","requestConversationFeedback":true,"windowStyle":"rounded","messages":{"en-US":{"compose.placeholder":"Type in here","feedback.prompt":"Do you want to give me feedback?","feedback.placeholder":"Write in your feedback here","logged.in":"Secure chat","close.window":"Close","back":"Back","privacy.policy":"Privacy policy","download.conversation":"Download conversation","delete.conversation":"Delete conversation","header.text":"Conversational AI","submit.message":"Send","submit.feedback":"Send","feedback.thumbs.up":"Satisfied with conversation","feedback.thumbs.down":"Not satisfied with conversation","message.thumbs.up":"Satisfied with answer","message.thumbs.down":"Not satisfied with answer","compose.characters.used":"{0} out of {1} characters used","minimize.window":"Minimize window","open.menu":"Open menu","opens.in.new.tab":"Opens in new tab","text.too.long":"The message cannot be longer than {0} characters","filter.select":"Select user group","upload.file":"Upload image","upload.file.error":"Upload failed","upload.file.progress":"Uploading ...","upload.file.success":"Upload successful"},"pt-BR":{"compose.placeholder":"Escreva aqui","feedback.prompt":"O que você achou do nosso serviço? Quer fazer um comentário?","feedback.placeholder":"Escreva seu comentário aqui","logged.in":"Chat seguro","header.text":"Conversational AI","submit.message":"Enviar","submit.feedback":"Enviar","feedback.thumbs.up":"Satisfeito com a conversa","feedback.thumbs.down":"Insatisfeito com a conversa","message.thumbs.up":"Satisfeito com a resposta","message.thumbs.down":"Insatisfeito com a resposta","compose.characters.used":"{0} sem {1} caracteres usados","minimize.window":"Minimizar janela","open.menu":"Ajuda / menu de exibição","opens.in.new.tab":"Abre em uma aba nova","text.too.long":"A mensagem não pode ter mais do que {0} caracteres","upload.file":"Carregar arquivo","upload.file.error":"Erro ao carregar","upload.file.progress":"Carregando...","upload.file.success":"Carregar concluído"},"da-DK":{"compose.placeholder":"Stil dit spørgsmål her...","feedback.prompt":"Du er velkommen til at give mig feedback","feedback.placeholder":"Skriv her","logged.in":"Sikker chat","header.text":"Conversational AI","submit.message":"Send","submit.feedback":"Send","feedback.thumbs.up":"Tilfreds med samtalen","feedback.thumbs.down":"Utilfreds med samtalen","message.thumbs.up":"Tilfreds med svaret","message.thumbs.down":"Utilfreds med svaret","compose.characters.used":"{0} af {1} tegn brugt","minimize.window":"Minimer vindue","open.menu":"Hjælp / Åbne menu","opens.in.new.tab":"Åbnes i ny fane","text.too.long":"Beskeden kan maksimalt indeholde {0} tegn","filter.select":"Vælg brugergruppe","upload.file":"Upload fil","upload.file.error":"Upload fejlet","upload.file.progress":"Sender","upload.file.success":"Upload fuldført"},"sv-SE":{"compose.placeholder":"Ställ din fråga här","feedback.prompt":"Vill du ge mig feedback?","feedback.placeholder":"Skriv här","logged.in":"Säker chat","close.window":"Stäng","privacy.policy":"Integritetspolicy","download.conversation":"Ladda ner samtal","delete.conversation":"Ta bort samtal","back":"Tillbaka","header.text":"Conversational AI","submit.message":"Skicka","submit.feedback":"Skicka","feedback.thumbs.up":"Nöjd med samtalet","feedback.thumbs.down":"Inte nöjd med samtalet","message.thumbs.up":"Nöjd med svaret","message.thumbs.down":"Inte nöjd med svaret","compose.characters.used":"{0} av {1} tecken använt","minimize.window":"Minimera fönster","open.menu":"Hjälp / Ôppna meny","opens.in.new.tab":"Öppnas i ny flik","text.too.long":"Meddelandet kan innehålla maximalt {0} tecken","filter.select":"Välj användargrupp","upload.file":"Ladda upp fil","upload.file.error":"Uppladdningen misslyckades","upload.file.progress":"Laddar","upload.file.success":"Uppladdningen lyckades"},"es-ES":{"compose.placeholder":"Formule su pregunta aquí","header.text":"Conversational AI","close.window":"Cerrar","download.conversation":"Descargar conversación","delete.conversation":"Borrar conversación","privacy.policy":"Política de privacidad","back":"Volver atrás","feedback.prompt":"¿Le gustaría darme su opinión?","feedback.placeholder":"Escriba sus comentarios aquí.","logged.in":"Chat seguro","submit.message":"Enviar","submit.feedback":"Enviar","feedback.thumbs.up":"Satisfecho con la conversación","feedback.thumbs.down":"Insatisfecho con la conversación","message.thumbs.up":"Satisfecho con la respuesta","message.thumbs.down":"Insatisfecho con la respuesta","compose.characters.used":"{0} de {1} caracteres utilizados","minimize.window":"Minimizar ventana","open.menu":"Ayuda / Desplegar menú","opens.in.new.tab":"Se abre en una pestaña nueva","text.too.long":"El mensaje no puede tener más de {0} caracteres","filter.select":"Seleccionar grupo de usuarios","upload.file":"Subir archivo","upload.file.error":"Error al cargar","upload.file.progress":"Cargando...","upload.file.success":"Carga completada"},"bn-BN":{"header.text":"Conversational AI"},"et-EE":{"header.text":"Conversational AI","opens.in.new.tab":"Avaneb uuel lehel","text.too.long":"Sõnum ei või olla pikem kui {0} märki"},"ur-UR":{"header.text":"Conversational AI"},"no-NO":{"header.text":"Conversational AI","compose.placeholder":"Still ditt spørsmål her","close.window":"Lukk","download.conversation":"Last ned samtalen","delete.conversation":"Slett samtalen","compose.characters.used":"{0} av {1} tegn brukt","submit.message":"Send","message.thumbs.up":"Fornøyd med svaret","message.thumbs.down":"Ikke fornøyd med svaret","minimize.window":"","open.menu":"","privacy.policy":"Personvern","back":"Tilbake","feedback.prompt":"Ønsker du å gi meg en tilbakemelding?","feedback.thumbs.up":"Fornøyd med samtalen","feedback.thumbs.down":"Ikke fornøyd med samtalen","feedback.placeholder":"Skriv din tilbakemelding her.","submit.feedback":"Send","logged.in":"Sikker chat","opens.in.new.tab":"Åpnes i ny fane","text.too.long":"Meldingen kan ikke være lenger enn {0} tegn","filter.select":"Velg brukergruppe","upload.file":"","upload.file.error":"","upload.file.progress":"","upload.file.success":""},"fi-FI":{"compose.placeholder":"Kirjoita kysymyksesi tähän","header.text":"Conversational AI","feedback.prompt":"Haluatko antaa palautetta?","feedback.placeholder":"Kirjoita palautteesi tähän","logged.in":"Suojattu chat","close.window":"","download.conversation":"","delete.conversation":"","privacy.policy":"","back":"","submit.message":"Lähetä","submit.feedback":"Lähetä","feedback.thumbs.up":"Tyytyväinen keskusteluun","feedback.thumbs.down":"Tyytymätön keskusteluun","message.thumbs.up":"Tyytyväinen vastaukseen","message.thumbs.down":"Tyytymätön vastaukseen","compose.characters.used":"{0} {1} merkistä käytetty","minimize.window":"Pienennä ikkuna","open.menu":"Apua / Avaa valikko","opens.in.new.tab":"Avaa uudessa välilehdessä","text.too.long":"Viestin maksimi merkkimäärä on {0}","filter.select":"Valitse käyttäjäryhmä","upload.file":"Lataa tiedosto","upload.file.error":"Lataus epäonnistui","upload.file.progress":"Lataus käynnissä","upload.file.success":"Lataus onnistui"},"de-DE":{"header.text":"Conversational AI","compose.placeholder":"Stelle deine Frage hier","compose.characters.used":"Stelle deine Frage hier","submit.message":"Nachricht senden","message.thumbs.up":"Zufrieden mit der Antwort","message.thumbs.down":"Unzufrieden mit der Antwort","minimize.window":"Minimieren","open.menu":"Hilfe / Menü öffnen ","close.window":"Schließen","download.conversation":"Gespräch downloaden","delete.conversation":"Gespräch löschen","privacy.policy":"Datenschutzbestimmungen","back":"Zurück","feedback.prompt":"Wir freuen uns über dein Feedback","feedback.thumbs.up":"Zufrieden mit dem Gespräch","feedback.thumbs.down":"Unzufrieden mit dem Gespräch","feedback.placeholder":"Schreibe hier dein Feedback","submit.feedback":"Senden","logged.in":"Sicherer Chat","opens.in.new.tab":"Öffnet sich in einem neuen Tab","text.too.long":"Die Nachricht darf nicht länger als {0} Zeichen sein","upload.file":"Daten hochladen","upload.file.error":"Fehler beim Hochladen","upload.file.progress":"Lädt","upload.file.success":"Erfolgreich hochgeladen"},"fr-FR":{"header.text":"Conversational AI","opens.in.new.tab":"Ouvre dans un nouvel onglet","text.too.long":"Le message ne peut pas contenir plus de {0} caractères"},"it-IT":{"header.text":"Conversational AI"},"nl-NL":{"header.text":"Conversational AI","compose.placeholder":"Typ hier je vraag","compose.characters.used":"Typ hier je vraag","submit.message":"Sturen","message.thumbs.up":"Tevreden met het antwoord","message.thumbs.down":"Ontevreden met het antwoord","minimize.window":"Venster verkleinen","open.menu":"Support / Menu openen","close.window":"Afsluiten","download.conversation":"Gesprek downloaden","delete.conversation":"Gesprek verwijderen","privacy.policy":"Privacybeleid","back":"Terugkeren","feedback.prompt":"Wij waarderen je feedback","feedback.thumbs.up":"Tevreden met het gesprek","feedback.thumbs.down":"Ontevreden met het gesprek","feedback.placeholder":"Typ hier je reactie","submit.feedback":"Sturen","logged.in":"Beveiligde chat","opens.in.new.tab":"Wordt in een nieuw tabblad geopend","text.too.long":"Het bericht mag maximaal {0} tekens bevatten","upload.file":"File uploaden","upload.file.error":"Upload mislukt","upload.file.progress":"Bezig met laden...","upload.file.success":"Bestand met succes geüpload"},"lt-LT":{"header.text":"Conversational AI","opens.in.new.tab":"Atidaryti naujame skirtuke","text.too.long":"Tekstas negali būti ilgesnis nei {0} simbolių"},"lv-LV":{"header.text":"Conversational AI","opens.in.new.tab":"Atvērt jaunā cilnē","text.too.long":"Ziņojums nedrīkst būt garāks par {0} rakstzīmēm"},"pl-PL":{"header.text":"Conversational AI","opens.in.new.tab":"Otwórz w nowej karcie","text.too.long":"Wiadomość nie może zawierać więcej niż {0} znaków"},"ru-RU":{"header.text":"Conversational AI"},"ro-RO":{"header.text":"Conversational AI"},"tr-TR":{"header.text":"Conversational AI"},"cs-CZ":{"header.text":"Conversational AI"},"hu-HU":{"header.text":"Conversational AI"},"ca-ES":{"header.text":"Conversational AI"},"ar-SA":{"header.text":"Conversational AI"},"el-GR":{"header.text":"Conversational AI"},"is-IS":{"back":"Til baka","close.window":"Loka","compose.characters.used":"{0} af {1} stöfum notaðir","compose.placeholder":"Hér geturðu sent okkur spurningu","delete.conversation":"Eyða samtali","download.conversation":"Hlaða niður samtali","feedback.placeholder":"Skrifaðu athugasemdir hér","feedback.prompt":"Vilt þú veita endurgjöf?","feedback.thumbs.down":"Ósátt/ur við samtalið","feedback.thumbs.up":"Sátt/ur við samtalið","header.text":"Sýndarfulltúi","logged.in":"Auðkennt spjall","message.thumbs.down":"Ekki sátt/ur við svarið","message.thumbs.up":"Sátt/ur við svarið","minimize.window":"Minnka glugga","open.menu":"Hjálp","privacy.policy":"Persónuverndarstefna","submit.feedback":"Senda","submit.message":"Senda","opens.in.new.tab":"Opnast í nýjum flipa","text.too.long":"Skilaboðin geta ekki verið lengri en {0} stafir","filter.select":"Veldu notendahóp","upload.file":"Hlaða upp skrá","upload.file.error":"Mistókst að hlaða upp skrá","upload.file.progress":"Hleður","upload.file.success":"Tókst að hlaða upp skrá"}},"clientMessageColor":"#363636","linkBelowColor":"#ffffff","avatarStyle":"square","spacingRight":80}
"""
let data = Data(str.utf8)


class ConfigTests: XCTestCase {
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
    }
    
    func test_parse_config() throws {
        let decoder = JSONDecoder()
        let formatter = DateFormatter.iso8601Full
        decoder.dateDecodingStrategy = .formatted(formatter)
        do {
            let config: ChatConfig = try decoder.decode(ChatConfig.self, from: data)
            XCTAssertTrue(config.linkBelowBackground=="#552a55")
            XCTAssertTrue(config.language(languageCode: "no-NO").back=="Tilbake")
            XCTAssertTrue(config.language(languageCode: "en-US").back=="Back")
            XCTAssertTrue(config.language(languageCode: "blabla").back=="Back")
            XCTAssertTrue(true)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func test_get_config_on_ready() throws {
        let backend = ChatBackend.shared
        backend.domain = "sdk.boost.ai"
        let stop = expectation(description: "Waiting for config command to finish")
        backend.onReady(completion: {
            (config, error) in
            guard error == nil else {
                XCTFail("\(String(describing: error))")
                return
            }
            if let config = config {
                XCTAssertTrue(config.linkBelowBackground=="#552a55")
                XCTAssertTrue(config.language(languageCode: "no-NO").back=="Tilbake")
                XCTAssertTrue(config.language(languageCode: "en-US").back=="Back")
                XCTAssertTrue(config.language(languageCode: "blabla").back=="Back")
            } else {
                XCTFail("No config")
            }
            stop.fulfill()
        })
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testZ_new_van_config() throws {
        let backend = ChatBackend.shared
        backend.domain = "sdk.boost.ai"
        let start = expectation(description: "Waiting for Start command to finish")
        let started = backend.newMessageObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            start.fulfill()
        }
        backend.start()
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            started.cancel()
        }
        /*
        let unblock = expectation(description: "Waiting for unblocking command to finish")
        let unblocked = backend.newMessageObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            unblock.fulfill()
        }
        backend.actionButton(id: backend.lastResponse!.response!.elements[1].payload.links![0].id)
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            unblocked.cancel()
        }
        */
        let lock = expectation(description: "Waiting for bilforsikring command to finish")
        var count = 0;
        let locked = backend.newMessageObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            count += 1
            if (count==2) {
                lock.fulfill()
            }
        }
        
        backend.message(value: "bilforsikring")
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            locked.cancel()
        }
        
        let link = expectation(description: "Waiting for va link")
        let linked = backend.newMessageObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            XCTAssertTrue(backend.vanId==5)
            link.fulfill()
        }
        let config = expectation(description: "Waiting for new config")
        let configed = backend.newConfigObserver(self) {
            message, error in
            
            if let error = error {
                XCTFail("\(error)")
            }
            XCTAssertTrue(backend.config?.avatarStyle == "rounded")
            config.fulfill()
        }
        
        backend.actionButton(id: backend.lastResponse!.response!.elements[1].payload.links![0].id)
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            linked.cancel()
            configed.cancel()
        }
        
    }
}
