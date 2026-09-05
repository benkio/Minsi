module Components.LoadingModal
  ( loadingModalExtraContentValues
  , loadingModalExtraContentRotation
  , parseLoadingModalExtraContentLabel
  ) where

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_loadingModalExtraContent)
import Data.Array (length, (!!))
import Data.Lens (view)
import Data.Maybe (Maybe(..))
import Data.String (split)
import Data.String.Pattern (Pattern(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect (Effect)
import Prelude
import Web.DOM.Document (Document, createElement)
import Web.DOM.Node as Node
import Web.HTML (window)
import Web.HTML.HTMLAnchorElement as HA
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.HTMLHyperlinkElementUtils (setHref)
import Web.HTML.HTMLSpanElement as HSP
import Web.HTML.Window (document)

type LoadingModalExtraContentValue =
  { label :: String
  , url :: String
  }

type ParsedLoadingModalExtraContentLabel =
  { date :: String
  , country :: String
  , event :: String
  }

parseLoadingModalExtraContentLabel :: String -> Maybe ParsedLoadingModalExtraContentLabel
parseLoadingModalExtraContentLabel label =
  case split (Pattern " - ") label of
    [ date, country, event ] -> Just { date, country, event }
    _ -> Nothing

loadingModalExtraContentRotation :: Int -> Aff Unit
loadingModalExtraContentRotation idx = do
  components <- liftEffect loadComponents
  w <- liftEffect window
  htmlDoc <- liftEffect $ document w
  let
    doc = toDocument htmlDoc
    span = view _loadingModalExtraContent components
    maybeExtraContent = loadingModalExtraContentValues !! (idx `mod` length loadingModalExtraContentValues)
    spanNode = HSP.toNode span
  liftEffect do
    Node.setTextContent "" spanNode
    case maybeExtraContent of
      Nothing -> pure unit
      Just extraContent -> appendExtraContentLink doc spanNode extraContent

appendExtraContentLink :: Document -> Node.Node -> LoadingModalExtraContentValue -> Effect Unit
appendExtraContentLink doc spanNode extraContent = do
  anchorRaw <- createElement "a" doc
  case HA.fromElement anchorRaw of
    Nothing -> Node.setTextContent extraContent.label spanNode
    Just anchor -> do
      let anchorNode = HA.toNode anchor
      setHref extraContent.url (HA.toHTMLHyperlinkElementUtils anchor)
      HA.setTarget "_blank" anchor
      HA.setRel "noopener noreferrer" anchor
      Node.setTextContent extraContent.label anchorNode
      void $ Node.appendChild anchorNode spanNode

loadingModalExtraContentValues :: Array LoadingModalExtraContentValue
loadingModalExtraContentValues =
  [ { label: "28/06/1919 - France - Treaty of Versailles", url: "http://www.wikidata.org/entity/Q8736" }
  , { label: "02/03/1931 - Empire of Japan - March Incident", url: "http://www.wikidata.org/entity/Q516749" }
  , { label: "01/11/1934 - Empire of Japan - Military Academy incident", url: "http://www.wikidata.org/entity/Q3149891" }
  , { label: "08/07/1937 - Unknown - Second Sino-Japanese War", url: "http://www.wikidata.org/entity/Q170314" }
  , { label: "01/01/1939 - Unknown - World War II crimes in Poland", url: "http://www.wikidata.org/entity/Q636944" }
  , { label: "01/01/1939 - Poland - Battle of Cześniki", url: "http://www.wikidata.org/entity/Q9172900" }
  , { label: "01/01/1939 - Poland - Battle of Tomaszów Lubelski", url: "http://www.wikidata.org/entity/Q1814334" }
  , { label: "01/01/1939 - Ukraine - Battle of Lwów", url: "http://www.wikidata.org/entity/Q3636512" }
  , { label: "19/03/1939 - Spain - Iberian Pact", url: "http://www.wikidata.org/entity/Q884821" }
  , { label: "08/04/1939 - Albania - Battle of Durrës", url: "http://www.wikidata.org/entity/Q48779976" }
  , { label: "23/08/1939 - Unknown - Molotov–Ribbentrop Pact", url: "http://www.wikidata.org/entity/Q130796" }
  , { label: "23/08/1939 - Unknown - Secret Additional Protocol to the Molotov–Ribbentrop Pact", url: "http://www.wikidata.org/entity/Q4413308" }
  , { label: "01/09/1939 - Unknown - 1939 Invasion of Poland", url: "http://www.wikidata.org/entity/Q150812" }
  , { label: "01/09/1939 - Unknown - European Theater of World War II", url: "http://www.wikidata.org/entity/Q44700" }
  , { label: "01/09/1939 - Poland - Battle of Mława", url: "http://www.wikidata.org/entity/Q443587" }
  , { label: "01/09/1939 - Poland - Operation Tannenberg", url: "http://www.wikidata.org/entity/Q702638" }
  , { label: "02/09/1939 - Poland - Battle of Borowa Góra", url: "http://www.wikidata.org/entity/Q4870527" }
  , { label: "03/09/1939 - Unknown - Battle of the Atlantic", url: "http://www.wikidata.org/entity/Q157627" }
  , { label: "03/09/1939 - Unknown - sinking of the S.S. Athenia", url: "http://www.wikidata.org/entity/Q117883870" }
  , { label: "04/09/1939 - Poland - Q115498116", url: "http://www.wikidata.org/entity/Q115498116" }
  , { label: "06/09/1939 - Poland - Battle of Krasną", url: "http://www.wikidata.org/entity/Q114949753" }
  , { label: "08/09/1939 - Poland - Battle of Odrzywoł", url: "http://www.wikidata.org/entity/Q110390183" }
  , { label: "08/09/1939 - Poland - Defense of Ochota and Wola (1939)", url: "http://www.wikidata.org/entity/Q129565948" }
  , { label: "08/09/1939 - Poland - Siege of Warsaw", url: "http://www.wikidata.org/entity/Q182240" }
  , { label: "09/09/1939 - Poland - Battle of Hel", url: "http://www.wikidata.org/entity/Q704550" }
  , { label: "10/09/1939 - Poland - Battle of Jarosław", url: "http://www.wikidata.org/entity/Q4871309" }
  , { label: "10/09/1939 - Poland - Battle of Mrogą", url: "http://www.wikidata.org/entity/Q9172480" }
  , { label: "10/09/1939 - Poland - Trip to Wawrzyszew", url: "http://www.wikidata.org/entity/Q136414539" }
  , { label: "12/09/1939 - Poland - Raid on Okęcie and Załuski", url: "http://www.wikidata.org/entity/Q131101333" }
  , { label: "14/09/1939 - Belarus - Battle of Brześć Litewski", url: "http://www.wikidata.org/entity/Q694416" }
  , { label: "16/09/1939 - Poland - Battle of Biłgorajem", url: "http://www.wikidata.org/entity/Q63373294" }
  , { label: "17/09/1939 - Unknown - Soviet invasion of Poland", url: "http://www.wikidata.org/entity/Q2305266" }
  , { label: "18/09/1939 - Lithuania - Battle of Wilno", url: "http://www.wikidata.org/entity/Q4090297" }
  , { label: "22/09/1939 - Poland - Battle of Krasnobród", url: "http://www.wikidata.org/entity/Q4871491" }
  , { label: "22/09/1939 - Poland - Skirmish near Kalety", url: "http://www.wikidata.org/entity/Q135278591" }
  , { label: "26/09/1939 - Ukraine - Battle of Władypol", url: "http://www.wikidata.org/entity/Q9173719" }
  , { label: "14/10/1939 - United Kingdom - Sinking of HMS Royal Oak", url: "http://www.wikidata.org/entity/Q5710379" }
  , { label: "16/10/1939 - United Kingdom - Battle of the River Forth", url: "http://www.wikidata.org/entity/Q22115505" }
  , { label: "09/11/1939 - Poland - Zweite Sonderaktion Krakau", url: "http://www.wikidata.org/entity/Q9392223" }
  , { label: "09/11/1939 - Unknown - Q131581765", url: "http://www.wikidata.org/entity/Q131581765" }
  , { label: "29/11/1939 - Finland - Winter War", url: "http://www.wikidata.org/entity/Q134949" }
  , { label: "01/01/1940 - Unknown - Rallying of New Caledonia to Free France", url: "http://www.wikidata.org/entity/Q97173714" }
  , { label: "01/01/1940 - France - Q131342994", url: "http://www.wikidata.org/entity/Q131342994" }
  , { label: "01/01/1940 - France - Siege of Calais", url: "http://www.wikidata.org/entity/Q2219890" }
  , { label: "01/01/1940 - Nazi Germany - German Military Mission in Romania", url: "http://www.wikidata.org/entity/Q21040697" }
  , { label: "01/01/1940 - Nazi Germany - Operation Felix", url: "http://www.wikidata.org/entity/Q701542" }
  , { label: "01/01/1940 - Nazi Germany - Plan Kathleen", url: "http://www.wikidata.org/entity/Q2299750" }
  , { label: "01/01/1940 - Nazi Germany - bombardments of Venlo", url: "http://www.wikidata.org/entity/Q19845675" }
  , { label: "01/01/1940 - Norway - Norwegian heavy water sabotage", url: "http://www.wikidata.org/entity/Q327048" }
  , { label: "01/01/1940 - United Kingdom - Battle of Britain", url: "http://www.wikidata.org/entity/Q154720" }
  , { label: "15/02/1940 - Norway - Altmark Incident", url: "http://www.wikidata.org/entity/Q177283" }
  , { label: "18/02/1940 - Unknown - Operation Wikinger", url: "http://www.wikidata.org/entity/Q470571" }
  , { label: "01/04/1940 - Norway - Kampene i Lunner, Oppland", url: "http://www.wikidata.org/entity/Q19376844" }
  , { label: "01/04/1940 - Norway - Åndalsnes landings", url: "http://www.wikidata.org/entity/Q3535001" }
  , { label: "09/04/1940 - Unknown - Action off Lofoten", url: "http://www.wikidata.org/entity/Q1764599" }
  , { label: "09/04/1940 - Unknown - German invasion of Denmark", url: "http://www.wikidata.org/entity/Q2308186" }
  , { label: "09/04/1940 - Unknown - German occupation of Norway", url: "http://www.wikidata.org/entity/Q819274" }
  , { label: "09/04/1940 - Unknown - Norwegian Campaign", url: "http://www.wikidata.org/entity/Q5084679" }
  , { label: "09/04/1940 - Norway - Battle of Drøbak Sound", url: "http://www.wikidata.org/entity/Q567787" }
  , { label: "09/04/1940 - Norway - Battle of Horten Harbour", url: "http://www.wikidata.org/entity/Q24997628" }
  , { label: "10/04/1940 - Norway - Battle of Midtskogen", url: "http://www.wikidata.org/entity/Q1061048" }
  , { label: "13/04/1940 - Faroe Islands - British occupation of the Faroe Islands", url: "http://www.wikidata.org/entity/Q929437" }
  , { label: "23/04/1940 - Norway - Battle of Gratangen", url: "http://www.wikidata.org/entity/Q4871135" }
  , { label: "24/04/1940 - Norway - Battle of Høljarast Bridge", url: "http://www.wikidata.org/entity/Q48778693" }
  , { label: "25/04/1940 - Norway - Battle for Kvam", url: "http://www.wikidata.org/entity/Q56063313" }
  , { label: "26/04/1940 - Norway - Battle of Eiunna Bridge", url: "http://www.wikidata.org/entity/Q113239692" }
  , { label: "01/05/1940 - Unknown - Hitler Appoints Arthur Seyss-Inquart  Reich Commissioner of the Occupied Netherlands in May 1940", url: "http://www.wikidata.org/entity/Q61791496" }
  , { label: "01/05/1940 - Belgium - Bombardment Sint-Niklaas", url: "http://www.wikidata.org/entity/Q122205763" }
  , { label: "03/05/1940 - Norway - Battle of Vinjesvingen", url: "http://www.wikidata.org/entity/Q2890351" }
  , { label: "10/05/1940 - Unknown - Operation NIWI", url: "http://www.wikidata.org/entity/Q123294681" }
  , { label: "10/05/1940 - Belgium - German invasion of Belgium", url: "http://www.wikidata.org/entity/Q697625" }
  , { label: "10/05/1940 - Netherlands - Battle for The Hague", url: "http://www.wikidata.org/entity/Q1891631" }
  , { label: "12/05/1940 - Belgium - Battle of Hannut", url: "http://www.wikidata.org/entity/Q2032618" }
  , { label: "12/05/1940 - Netherlands - Battle of the Afsluitdijk", url: "http://www.wikidata.org/entity/Q714979" }
  , { label: "13/05/1940 - France - Battle of Sedan", url: "http://www.wikidata.org/entity/Q269207" }
  , { label: "14/05/1940 - Belgium - Battle of Gembloux", url: "http://www.wikidata.org/entity/Q714265" }
  , { label: "14/05/1940 - Netherlands - German invasion of the Netherlands", url: "http://www.wikidata.org/entity/Q2649081" }
  , { label: "15/05/1940 - France - Battle of La Horgne", url: "http://www.wikidata.org/entity/Q2889059" }
  , { label: "16/05/1940 - Belgium - Battle of Leuven", url: "http://www.wikidata.org/entity/Q1527360" }
  , { label: "17/05/1940 - France - Battle of Montcornet", url: "http://www.wikidata.org/entity/Q2889367" }
  , { label: "21/05/1940 - France - Battle of Arras", url: "http://www.wikidata.org/entity/Q696839" }
  , { label: "25/05/1940 - France - Battle of Stonne", url: "http://www.wikidata.org/entity/Q2890071" }
  , { label: "26/05/1940 - France - Battle of Dunkirk", url: "http://www.wikidata.org/entity/Q208529" }
  , { label: "26/05/1940 - France - Belgian share in the evacuation of Dunkirk", url: "http://www.wikidata.org/entity/Q77245550" }
  , { label: "01/06/1940 - Kingdom of Italy - Bombing of Genoa in World War II", url: "http://www.wikidata.org/entity/Q86675044" }
  , { label: "04/06/1940 - France - Battle of Abbeville", url: "http://www.wikidata.org/entity/Q2237269" }
  , { label: "07/06/1940 - Unknown - Battle of Ailette", url: "http://www.wikidata.org/entity/Q1391945" }
  , { label: "08/06/1940 - France - Battle of Amiens", url: "http://www.wikidata.org/entity/Q548775" }
  , { label: "10/06/1940 - Ethiopia - Mediterranean and Middle East Theater of World War II", url: "http://www.wikidata.org/entity/Q696817" }
  , { label: "10/06/1940 - Kingdom of Italy - Declaration of war on Great Britain and France", url: "http://www.wikidata.org/entity/Q20950199" }
  , { label: "11/06/1940 - Malta - Siege of Malta", url: "http://www.wikidata.org/entity/Q682452" }
  , { label: "12/06/1940 - Unknown - Battle of the Aisne", url: "http://www.wikidata.org/entity/Q1441594" }
  , { label: "14/06/1940 - Francoist Spain - Spanish occupation of Tangier", url: "http://www.wikidata.org/entity/Q86756565" }
  , { label: "20/06/1940 - Faroe Islands - Psilander Affair", url: "http://www.wikidata.org/entity/Q7130016" }
  , { label: "25/06/1940 - Unknown - Operation Collar", url: "http://www.wikidata.org/entity/Q7096915" }
  , { label: "28/06/1940 - France - Battle of Pont Saint-Louis", url: "http://www.wikidata.org/entity/Q2889636" }
  , { label: "28/06/1940 - Moldova - Soviet occupation of Bessarabia and Northern Bukovina", url: "http://www.wikidata.org/entity/Q2266004" }
  , { label: "30/06/1940 - Guernsey - German occupation of the Channel Islands", url: "http://www.wikidata.org/entity/Q2238977" }
  , { label: "09/07/1940 - Italy - Action off Calabria", url: "http://www.wikidata.org/entity/Q635150" }
  , { label: "15/07/1940 - Guernsey - Operation Ambassador", url: "http://www.wikidata.org/entity/Q2750804" }
  , { label: "20/07/1940 - France - Zone interdite", url: "http://www.wikidata.org/entity/Q3575908" }
  , { label: "04/08/1940 - Unknown - Operation Hurry", url: "http://www.wikidata.org/entity/Q17152091" }
  , { label: "01/09/1940 - Nazi Germany - Operation Sea Lion", url: "http://www.wikidata.org/entity/Q153341" }
  , { label: "04/09/1940 - Unknown - Convoy FS 271", url: "http://www.wikidata.org/entity/Q16837895" }
  , { label: "08/09/1940 - Unknown - Convoy SC 2", url: "http://www.wikidata.org/entity/Q5166660" }
  , { label: "08/09/1940 - Unknown - Italian bombing of Mandatory Palestine in World War II", url: "http://www.wikidata.org/entity/Q2638412" }
  , { label: "13/09/1940 - Unknown - Ip massacre", url: "http://www.wikidata.org/entity/Q1503007" }
  , { label: "22/09/1940 - Senegal - Battle of Dakar", url: "http://www.wikidata.org/entity/Q696829" }
  , { label: "26/09/1940 - United Kingdom - Battle of Graveney Marsh", url: "http://www.wikidata.org/entity/Q4871136" }
  , { label: "01/10/1940 - Unknown - Franco-Thai War", url: "http://www.wikidata.org/entity/Q780845" }
  , { label: "21/10/1940 - Unknown - Attack on Convoy BN 7", url: "http://www.wikidata.org/entity/Q17513965" }
  , { label: "28/10/1940 - Unknown - World War II in the Balkans", url: "http://www.wikidata.org/entity/Q162362" }
  , { label: "31/10/1940 - France - Q131296669", url: "http://www.wikidata.org/entity/Q131296669" }
  , { label: "10/11/1940 - Italy - Battle of Taranto", url: "http://www.wikidata.org/entity/Q543255" }
  , { label: "11/11/1940 - Italy - Battle of the Strait of Otranto", url: "http://www.wikidata.org/entity/Q2200263" }
  , { label: "19/11/1940 - Romania - November 20, 1940, Romania formally joined the Axis alliance (Germany, Italy, and Japan)", url: "http://www.wikidata.org/entity/Q112600021" }
  , { label: "26/11/1940 - Unknown - Battle of Cape Spartivento", url: "http://www.wikidata.org/entity/Q1541340" }
  , { label: "01/01/1941 - Unknown - Battle of Vevi", url: "http://www.wikidata.org/entity/Q3174617" }
  , { label: "01/01/1941 - Unknown - Battle of the Caribbean", url: "http://www.wikidata.org/entity/Q443057" }
  , { label: "01/01/1941 - Belarus - Battle of Minsk", url: "http://www.wikidata.org/entity/Q96195581" }
  , { label: "01/01/1941 - Russia - Battle of Rostov", url: "http://www.wikidata.org/entity/Q169436" }
  , { label: "01/01/1941 - Ukraine - The Holocaust in Romania", url: "http://www.wikidata.org/entity/Q3376121" }
  , { label: "02/01/1941 - Libya - Battle of Bardia", url: "http://www.wikidata.org/entity/Q2426368" }
  , { label: "15/01/1941 - Unknown - Battle of Ko Chang", url: "http://www.wikidata.org/entity/Q702579" }
  , { label: "20/01/1941 - Libya - British capture of Tobruk", url: "http://www.wikidata.org/entity/Q76643875" }
  , { label: "21/01/1941 - Unknown - Convoy SC 20", url: "http://www.wikidata.org/entity/Q16933423" }
  , { label: "31/01/1941 - Germany - Q71965308", url: "http://www.wikidata.org/entity/Q71965308" }
  , { label: "01/02/1941 - Unknown - Convoy SC 19", url: "http://www.wikidata.org/entity/Q16933420" }
  , { label: "04/02/1941 - Eritrea - Battle of Keren", url: "http://www.wikidata.org/entity/Q1970005" }
  , { label: "09/02/1941 - Unknown - Operation Colossus", url: "http://www.wikidata.org/entity/Q3883950" }
  , { label: "18/02/1941 - United Kingdom - Swansea Blitz", url: "http://www.wikidata.org/entity/Q7653662" }
  , { label: "02/03/1941 - United Kingdom - Clydebank Blitz", url: "http://www.wikidata.org/entity/Q5137071" }
  , { label: "04/03/1941 - Netherlands - Bombing of Eindhoven Gas Holder in World War II", url: "http://www.wikidata.org/entity/Q109450882" }
  , { label: "05/03/1941 - Norway - Operation Claymore", url: "http://www.wikidata.org/entity/Q1233004" }
  , { label: "02/04/1941 - Greece - Axis occupation of Greece", url: "http://www.wikidata.org/entity/Q703550" }
  , { label: "02/04/1941 - Greece - Battle of Greece", url: "http://www.wikidata.org/entity/Q2888837" }
  , { label: "05/04/1941 - Unknown - Action of 4 April 1941", url: "http://www.wikidata.org/entity/Q4677364" }
  , { label: "06/04/1941 - Unknown - Convoy SC 26", url: "http://www.wikidata.org/entity/Q5166661" }
  , { label: "07/04/1941 - Bulgaria - Kyustendil Air Raid", url: "http://www.wikidata.org/entity/Q1123160" }
  , { label: "07/04/1941 - Serbia - Bombing of Belgrade in 1941", url: "http://www.wikidata.org/entity/Q472100" }
  , { label: "07/04/1941 - Yugoslavia - World War II in Yugoslavia", url: "http://www.wikidata.org/entity/Q626006" }
  , { label: "10/04/1941 - Norway - Bombing of Høyanger", url: "http://www.wikidata.org/entity/Q12713860" }
  , { label: "18/04/1941 - Unknown - Invasion of Yugoslavia", url: "http://www.wikidata.org/entity/Q697842" }
  , { label: "02/05/1941 - Unknown - Middle East Theater of World War II", url: "http://www.wikidata.org/entity/Q871373" }
  , { label: "05/05/1941 - Unknown - Second Battle of Amba Alagi", url: "http://www.wikidata.org/entity/Q1410792" }
  , { label: "09/05/1941 - Unknown - Action of 8 May 1941", url: "http://www.wikidata.org/entity/Q4677388" }
  , { label: "21/05/1941 - Greece - Battle of Heraklion", url: "http://www.wikidata.org/entity/Q4871210" }
  , { label: "21/05/1941 - Greece - Battle of Rethymno", url: "http://www.wikidata.org/entity/Q4872174" }
  , { label: "28/05/1941 - Unknown - Battle of 42nd Street", url: "http://www.wikidata.org/entity/Q4870203" }
  , { label: "16/06/1941 - Iceland - Allied occupation of Iceland", url: "http://www.wikidata.org/entity/Q2050460" }
  , { label: "22/06/1941 - Unknown - National Liberation War and Socialist Revolution", url: "http://www.wikidata.org/entity/Q127247663" }
  , { label: "22/06/1941 - Romania - Q130282483", url: "http://www.wikidata.org/entity/Q130282483" }
  , { label: "23/06/1941 - Ukraine - Battle of Brody", url: "http://www.wikidata.org/entity/Q708213" }
  , { label: "25/06/1941 - Unknown - Continuation War", url: "http://www.wikidata.org/entity/Q122100" }
  , { label: "26/06/1941 - Kingdom of Hungary - Kassa attack", url: "http://www.wikidata.org/entity/Q1035922" }
  , { label: "29/06/1941 - Latvia - Liepāja Massacres", url: "http://www.wikidata.org/entity/Q2915791" }
  , { label: "10/07/1941 - Unknown - Battle of Białystok–Minsk", url: "http://www.wikidata.org/entity/Q327061" }
  , { label: "13/07/1941 - Unknown - Convoy SL 78", url: "http://www.wikidata.org/entity/Q16931765" }
  , { label: "13/07/1941 - Francoist Spain - Bombing of La Línea de la Concepción", url: "http://www.wikidata.org/entity/Q5731782" }
  , { label: "16/07/1941 - Unknown - Battle of Uman", url: "http://www.wikidata.org/entity/Q327078" }
  , { label: "26/07/1941 - Unknown - Battle of Grand Harbour", url: "http://www.wikidata.org/entity/Q2026616" }
  , { label: "01/08/1941 - Unknown - Arctic convoys of World War II", url: "http://www.wikidata.org/entity/Q1505845" }
  , { label: "01/08/1941 - Unknown - Convoy OG 69", url: "http://www.wikidata.org/entity/Q16934382" }
  , { label: "01/08/1941 - Unknown - Finnish reconquest of Ladoga Karelia", url: "http://www.wikidata.org/entity/Q2756517" }
  , { label: "08/08/1941 - Ukraine - Siege of Odesa 1941", url: "http://www.wikidata.org/entity/Q682409" }
  , { label: "25/08/1941 - Unknown - Convoy OG 71", url: "http://www.wikidata.org/entity/Q16934384" }
  , { label: "25/08/1941 - Unknown - Operation Gauntlet", url: "http://www.wikidata.org/entity/Q1324220" }
  , { label: "31/08/1941 - Unknown - Soviet evacuation of Tallinn", url: "http://www.wikidata.org/entity/Q836124" }
  , { label: "12/09/1941 - Unknown - Convoy SC 42", url: "http://www.wikidata.org/entity/Q5166662" }
  , { label: "14/09/1941 - Unknown - Sabotage at the General Post Office in Zagreb", url: "http://www.wikidata.org/entity/Q2352528" }
  , { label: "27/09/1941 - Unknown - Operation Chopper", url: "http://www.wikidata.org/entity/Q7096898" }
  , { label: "27/09/1941 - Cape Verde - Action in Tarafal Bay", url: "http://www.wikidata.org/entity/Q4677216" }
  , { label: "01/10/1941 - Unknown - Vyazemsky operation", url: "http://www.wikidata.org/entity/Q319488" }
  , { label: "18/10/1941 - Unknown - Convoy SC 48", url: "http://www.wikidata.org/entity/Q5166663" }
  , { label: "09/11/1941 - Russia - Tikhvin offensive", url: "http://www.wikidata.org/entity/Q1657889" }
  , { label: "10/11/1941 - Soviet Union - Battle of Nikitovka", url: "http://www.wikidata.org/entity/Q137169573" }
  , { label: "18/11/1941 - Australia - Battle between HMAS Sydney and German auxiliary cruiser Kormoran", url: "http://www.wikidata.org/entity/Q58459" }
  , { label: "07/12/1941 - Unknown - American Theater", url: "http://www.wikidata.org/entity/Q2632857" }
  , { label: "07/12/1941 - Unknown - Asiatic-Pacific Theater", url: "http://www.wikidata.org/entity/Q12296445" }
  , { label: "07/12/1941 - Unknown - European-African-Middle Eastern Theater", url: "http://www.wikidata.org/entity/Q111976804" }
  , { label: "08/12/1941 - Unknown - Pacific War", url: "http://www.wikidata.org/entity/Q184425" }
  , { label: "14/12/1941 - Unknown - Symbolic War", url: "http://www.wikidata.org/entity/Q12293731" }
  , { label: "14/12/1941 - Malaysia - Battle of Gurun", url: "http://www.wikidata.org/entity/Q4871165" }
  , { label: "19/12/1941 - Unknown - Convoy HG 76", url: "http://www.wikidata.org/entity/Q3689898" }
  , { label: "24/12/1941 - Unknown - Capture of Saint Pierre and Miquelon", url: "http://www.wikidata.org/entity/Q3418131" }
  , { label: "27/12/1941 - Unknown - Operation Archery", url: "http://www.wikidata.org/entity/Q1964451" }
  , { label: "27/12/1941 - Norway - Operation Anklet", url: "http://www.wikidata.org/entity/Q2310240" }
  , { label: "01/01/1942 - Unknown - Air raid on Darwin on the 28th", url: "http://www.wikidata.org/entity/Q1710216" }
  , { label: "01/01/1942 - Unknown - Battle of Bowmanville", url: "http://www.wikidata.org/entity/Q4870537" }
  , { label: "01/01/1942 - Unknown - Battle of Dražgoše", url: "http://www.wikidata.org/entity/Q4870916" }
  , { label: "01/01/1942 - Unknown - Battle of Savo Island", url: "http://www.wikidata.org/entity/Q700032" }
  , { label: "01/01/1942 - Unknown - Battle of Tarakan", url: "http://www.wikidata.org/entity/Q2165376" }
  , { label: "01/01/1942 - Unknown - Operation Alba", url: "http://www.wikidata.org/entity/Q117258" }
  , { label: "01/01/1942 - Unknown - Operation Bernhard", url: "http://www.wikidata.org/entity/Q422326" }
  , { label: "01/01/1942 - Unknown - Operation Biting", url: "http://www.wikidata.org/entity/Q304403" }
  , { label: "01/01/1942 - Unknown - Q132175028", url: "http://www.wikidata.org/entity/Q132175028" }
  , { label: "01/01/1942 - Unknown - Q132181614", url: "http://www.wikidata.org/entity/Q132181614" }
  , { label: "01/01/1942 - Unknown - Q132396587", url: "http://www.wikidata.org/entity/Q132396587" }
  , { label: "01/01/1942 - Unknown - Q132452301", url: "http://www.wikidata.org/entity/Q132452301" }
  , { label: "01/01/1942 - Unknown - Q2667757", url: "http://www.wikidata.org/entity/Q2667757" }
  , { label: "01/01/1942 - Unknown - Q82326623", url: "http://www.wikidata.org/entity/Q82326623" }
  , { label: "01/01/1942 - Unknown - Torpedo Alley", url: "http://www.wikidata.org/entity/Q7826735" }
  , { label: "01/01/1942 - Unknown - United States Army Air Forces in Australia", url: "http://www.wikidata.org/entity/Q7889438" }
  , { label: "01/01/1942 - Unknown - World War II in Albania", url: "http://www.wikidata.org/entity/Q74109" }
  , { label: "01/01/1942 - Brazil - Plan Rubber", url: "http://www.wikidata.org/entity/Q7200903" }
  , { label: "01/01/1942 - Norway - Operation Hardboiled", url: "http://www.wikidata.org/entity/Q7097117" }
  , { label: "01/01/1942 - Russia - Battle of Voronezh", url: "http://www.wikidata.org/entity/Q695943" }
  , { label: "01/01/1942 - Yugoslavia - Operation Alfa", url: "http://www.wikidata.org/entity/Q104841141" }
  , { label: "07/01/1942 - Unknown - Rzhev-Vyazma offensive", url: "http://www.wikidata.org/entity/Q2034438" }
  , { label: "07/01/1942 - Russia - Battles of Rzhev", url: "http://www.wikidata.org/entity/Q261776" }
  , { label: "13/01/1942 - Unknown - Battle of Muar", url: "http://www.wikidata.org/entity/Q2889419" }
  , { label: "13/01/1942 - Unknown - Operation Postmaster", url: "http://www.wikidata.org/entity/Q1775224" }
  , { label: "13/01/1942 - Soviet Union - Q21636225", url: "http://www.wikidata.org/entity/Q21636225" }
  , { label: "29/01/1942 - Unknown - Battle of Ambon", url: "http://www.wikidata.org/entity/Q2392991" }
  , { label: "31/01/1942 - Unknown - Q10494502", url: "http://www.wikidata.org/entity/Q10494502" }
  , { label: "31/01/1942 - France - Battle for Australia", url: "http://www.wikidata.org/entity/Q2890968" }
  , { label: "01/02/1942 - Unknown - Operation Ozren", url: "http://www.wikidata.org/entity/Q3354866" }
  , { label: "03/02/1942 - Unknown - Battle of Makassar Strait", url: "http://www.wikidata.org/entity/Q80264" }
  , { label: "07/02/1942 - Singapore - Battle of Singapore", url: "http://www.wikidata.org/entity/Q296754" }
  , { label: "11/02/1942 - Unknown - Operation Donnerkeil", url: "http://www.wikidata.org/entity/Q3883953" }
  , { label: "14/02/1942 - Unknown - Convoy SC 67", url: "http://www.wikidata.org/entity/Q17017712" }
  , { label: "15/02/1942 - Unknown - Attack on Aruba", url: "http://www.wikidata.org/entity/Q543043" }
  , { label: "18/02/1942 - Indonesia - Battle of Timor", url: "http://www.wikidata.org/entity/Q1440764" }
  , { label: "23/02/1942 - United States - Battle of Los Angeles", url: "http://www.wikidata.org/entity/Q1066650" }
  , { label: "26/02/1942 - Indonesia - Battle of Sunda Strait", url: "http://www.wikidata.org/entity/Q1536686" }
  , { label: "26/02/1942 - Myanmar - Operation Caesar", url: "http://www.wikidata.org/entity/Q114321849" }
  , { label: "02/03/1942 - Unknown - Operation Neuland", url: "http://www.wikidata.org/entity/Q7097319" }
  , { label: "02/03/1942 - Unknown - Operation Sportpalast", url: "http://www.wikidata.org/entity/Q3354855" }
  , { label: "02/03/1942 - Unknown - Second Battle of the Java Sea", url: "http://www.wikidata.org/entity/Q2440134" }
  , { label: "02/03/1942 - Latvia - Dünamünde Action", url: "http://www.wikidata.org/entity/Q422352" }
  , { label: "04/03/1942 - Australia - Attack on Broome", url: "http://www.wikidata.org/entity/Q1875552" }
  , { label: "07/03/1942 - Dutch East Indies - Bombing of Sukabumi", url: "http://www.wikidata.org/entity/Q105649597" }
  , { label: "08/03/1942 - Unknown - Battle of Tjiater Pass", url: "http://www.wikidata.org/entity/Q83834887" }
  , { label: "27/03/1942 - Soviet Union - Operation Bamberg", url: "http://www.wikidata.org/entity/Q3354645" }
  , { label: "28/03/1942 - Unknown - Action of 27 March 1942", url: "http://www.wikidata.org/entity/Q3631507" }
  , { label: "30/03/1942 - Unknown - Hukbalahap Rebellion", url: "http://www.wikidata.org/entity/Q5935403" }
  , { label: "30/03/1942 - Germany - Bombing of Lübeck in World War II", url: "http://www.wikidata.org/entity/Q471625" }
  , { label: "01/04/1942 - Australia - Battle of Christmas Island", url: "http://www.wikidata.org/entity/Q1361210" }
  , { label: "05/04/1942 - Unknown - Q2072027", url: "http://www.wikidata.org/entity/Q2072027" }
  , { label: "06/04/1942 - Unknown - Easter Sunday Raid", url: "http://www.wikidata.org/entity/Q5329907" }
  , { label: "15/04/1942 - Unknown - Convoy OG 82", url: "http://www.wikidata.org/entity/Q5166637" }
  , { label: "17/04/1942 - Germany - Augsburg raid", url: "http://www.wikidata.org/entity/Q55604480" }
  , { label: "18/04/1942 - Slovenia - Battle of Nanos", url: "http://www.wikidata.org/entity/Q4871857" }
  , { label: "02/05/1942 - Unknown - Battle of the St. Lawrence", url: "http://www.wikidata.org/entity/Q1993443" }
  , { label: "06/05/1942 - Madagascar - Battle of Madagascar", url: "http://www.wikidata.org/entity/Q1052651" }
  , { label: "09/05/1942 - Unknown - Cocos Islands Mutiny", url: "http://www.wikidata.org/entity/Q179272" }
  , { label: "14/05/1942 - Unknown - Action of 13 May 1942", url: "http://www.wikidata.org/entity/Q16056962" }
  , { label: "17/05/1942 - Unknown - Q131468303", url: "http://www.wikidata.org/entity/Q131468303" }
  , { label: "28/05/1942 - Unknown - Operation Anthropoid", url: "http://www.wikidata.org/entity/Q715264" }
  , { label: "02/06/1942 - Russia - Operation Hannover", url: "http://www.wikidata.org/entity/Q7097115" }
  , { label: "03/06/1942 - Egypt - Battle at Bir el Harmat", url: "http://www.wikidata.org/entity/Q1317908" }
  , { label: "05/06/1942 - United States - Battle of Dutch Harbor", url: "http://www.wikidata.org/entity/Q543075" }
  , { label: "08/06/1942 - Australia - Attack on Sydney Harbour", url: "http://www.wikidata.org/entity/Q2659473" }
  , { label: "17/06/1942 - Unknown - Convoy HG 84", url: "http://www.wikidata.org/entity/Q5166615" }
  , { label: "18/06/1942 - Czech Republic - Fight at the Saints Cyril and Methodius Cathedral", url: "http://www.wikidata.org/entity/Q4845406" }
  , { label: "02/07/1942 - Unknown - Operation Herkules", url: "http://www.wikidata.org/entity/Q705332" }
  , { label: "03/07/1942 - Russia - Operation Seydlitz", url: "http://www.wikidata.org/entity/Q2069830" }
  , { label: "20/07/1942 - Russia - Battle of Rostov", url: "http://www.wikidata.org/entity/Q2889816" }
  , { label: "21/07/1942 - Unknown - Q131841090", url: "http://www.wikidata.org/entity/Q131841090" }
  , { label: "23/07/1942 - Soviet Union - Operation Fischreiher", url: "http://www.wikidata.org/entity/Q3658262" }
  , { label: "28/07/1942 - Unknown - Q132174093", url: "http://www.wikidata.org/entity/Q132174093" }
  , { label: "29/07/1942 - Unknown - Battle of Kokoda", url: "http://www.wikidata.org/entity/Q27628328" }
  , { label: "31/07/1942 - Unknown - Convoy ON 113", url: "http://www.wikidata.org/entity/Q16931276" }
  , { label: "07/08/1942 - Unknown - Battle of Tulagi and Gavutu–Tanambogo", url: "http://www.wikidata.org/entity/Q1497996" }
  , { label: "08/08/1942 - Unknown - Convoy ON 115", url: "http://www.wikidata.org/entity/Q16931282" }
  , { label: "24/08/1942 - Unknown - Battle of the Eastern Solomons", url: "http://www.wikidata.org/entity/Q696479" }
  , { label: "29/08/1942 - Unknown - Makarska massacre", url: "http://www.wikidata.org/entity/Q16085087" }
  , { label: "31/08/1942 - Unknown - Battle of Isurava", url: "http://www.wikidata.org/entity/Q27548777" }
  , { label: "02/09/1942 - Unknown - Northern Campaign", url: "http://www.wikidata.org/entity/Q7058215" }
  , { label: "03/09/1942 - Unknown - Convoy LN-7", url: "http://www.wikidata.org/entity/Q18127482" }
  , { label: "05/09/1942 - Unknown - First Battle of Eora Creek – Templeton's Crossing", url: "http://www.wikidata.org/entity/Q30687498" }
  , { label: "09/09/1942 - Unknown - Battle of Mission Ridge – Brigade Hill", url: "http://www.wikidata.org/entity/Q24883851" }
  , { label: "09/09/1942 - Unknown - Night operation", url: "http://www.wikidata.org/entity/Q117730161" }
  , { label: "10/09/1942 - Unknown - Convoy QS-33", url: "http://www.wikidata.org/entity/Q16931212" }
  , { label: "11/09/1942 - Unknown - Operation Musketoon", url: "http://www.wikidata.org/entity/Q3354778" }
  , { label: "16/09/1942 - Unknown - Battle of Ioribaiwa", url: "http://www.wikidata.org/entity/Q27627986" }
  , { label: "16/09/1942 - Unknown - Convoy SQ-36", url: "http://www.wikidata.org/entity/Q16932628" }
  , { label: "16/09/1942 - Unknown - Convoy TAG 5", url: "http://www.wikidata.org/entity/Q16933816" }
  , { label: "24/09/1942 - Norway - Oslo Mosquito raid", url: "http://www.wikidata.org/entity/Q7107032" }
  , { label: "25/09/1942 - Unknown - Convoy QP 14", url: "http://www.wikidata.org/entity/Q15811564" }
  , { label: "26/09/1942 - Unknown - Battle of SS Stephen Hopkins", url: "http://www.wikidata.org/entity/Q67322153" }
  , { label: "27/09/1942 - Unknown - Convoy SC 100", url: "http://www.wikidata.org/entity/Q16933433" }
  , { label: "27/09/1942 - Unknown - Convoys SG-6/LN-6", url: "http://www.wikidata.org/entity/Q16827862" }
  , { label: "01/10/1942 - Unknown - Gata massacre", url: "http://www.wikidata.org/entity/Q12959187" }
  , { label: "04/10/1942 - Guernsey - Operation Basalt", url: "http://www.wikidata.org/entity/Q2225555" }
  , { label: "10/10/1942 - Unknown - Q132407023", url: "http://www.wikidata.org/entity/Q132407023" }
  , { label: "11/10/1942 - Unknown - Battle of Cape Esperance", url: "http://www.wikidata.org/entity/Q1475243" }
  , { label: "22/10/1942 - Unknown - Battle of Goodenough Island", url: "http://www.wikidata.org/entity/Q4871126" }
  , { label: "24/10/1942 - North Macedonia - Q1572745", url: "http://www.wikidata.org/entity/Q1572745" }
  , { label: "28/10/1942 - Unknown - Second Battle of Eora Creek – Templeton's Crossing", url: "http://www.wikidata.org/entity/Q30687676" }
  , { label: "01/11/1942 - Unknown - Q131914608", url: "http://www.wikidata.org/entity/Q131914608" }
  , { label: "07/11/1942 - Unknown - Q82476482", url: "http://www.wikidata.org/entity/Q82476482" }
  , { label: "08/11/1942 - Unknown - Convoy TAG 18", url: "http://www.wikidata.org/entity/Q16933802" }
  , { label: "10/11/1942 - Unknown - Battle of Oivi–Gorari", url: "http://www.wikidata.org/entity/Q24884194" }
  , { label: "10/11/1942 - Unknown - Convoy TAG 19", url: "http://www.wikidata.org/entity/Q16933810" }
  , { label: "10/11/1942 - Unknown - Q82314139", url: "http://www.wikidata.org/entity/Q82314139" }
  , { label: "15/11/1942 - Unknown - Operation Torch", url: "http://www.wikidata.org/entity/Q194132" }
  , { label: "17/11/1942 - Unknown - Q2498287", url: "http://www.wikidata.org/entity/Q2498287" }
  , { label: "18/11/1942 - Russia - Battle for Velikiye Luki", url: "http://www.wikidata.org/entity/Q701195" }
  , { label: "05/12/1942 - Unknown - Operation Portcullis", url: "http://www.wikidata.org/entity/Q1887379" }
  , { label: "06/12/1942 - Netherlands - Operation Oyster", url: "http://www.wikidata.org/entity/Q42886508" }
  , { label: "11/12/1942 - Unknown - Convoy ON 153", url: "http://www.wikidata.org/entity/Q16931288" }
  , { label: "11/12/1942 - Libya - Battle of El Agheila", url: "http://www.wikidata.org/entity/Q2371769" }
  , { label: "11/12/1942 - Russia - Second Defensive Battle at the Don", url: "http://www.wikidata.org/entity/Q3953973" }
  , { label: "17/12/1942 - Unknown - Q124759592", url: "http://www.wikidata.org/entity/Q124759592" }
  , { label: "31/12/1942 - Unknown - Battle of the Barents Sea", url: "http://www.wikidata.org/entity/Q699411" }
  , { label: "01/01/1943 - Unknown - Case Black", url: "http://www.wikidata.org/entity/Q124172206" }
  , { label: "01/01/1943 - Unknown - Operation Autonomous", url: "http://www.wikidata.org/entity/Q7096772" }
  , { label: "01/01/1943 - Unknown - Operation Cartoon", url: "http://www.wikidata.org/entity/Q4036881" }
  , { label: "01/01/1943 - Unknown - Operation Longcloth", url: "http://www.wikidata.org/entity/Q12797937" }
  , { label: "01/01/1943 - Unknown - Operation Python", url: "http://www.wikidata.org/entity/Q7097430" }
  , { label: "01/01/1943 - Unknown - Q116296901", url: "http://www.wikidata.org/entity/Q116296901" }
  , { label: "01/01/1943 - Unknown - Q131905786", url: "http://www.wikidata.org/entity/Q131905786" }
  , { label: "01/01/1943 - Unknown - Q132010508", url: "http://www.wikidata.org/entity/Q132010508" }
  , { label: "01/01/1943 - Unknown - Q132077094", url: "http://www.wikidata.org/entity/Q132077094" }
  , { label: "01/01/1943 - Belarus - Operation Hornung", url: "http://www.wikidata.org/entity/Q7097142" }
  , { label: "01/01/1943 - France - Italian occupation of Corsica", url: "http://www.wikidata.org/entity/Q3075488" }
  , { label: "01/01/1943 - Italy - Bombing of Foggia", url: "http://www.wikidata.org/entity/Q3641947" }
  , { label: "01/01/1943 - Norway - Operation Carhampton", url: "http://www.wikidata.org/entity/Q11993905" }
  , { label: "01/01/1943 - Norway - Operation Martin", url: "http://www.wikidata.org/entity/Q19384597" }
  , { label: "01/01/1943 - Norway - Submarine attack on Svensgrunnen", url: "http://www.wikidata.org/entity/Q25428353" }
  , { label: "01/01/1943 - Russia - Battle of Nikolayevka", url: "http://www.wikidata.org/entity/Q1132971" }
  , { label: "01/01/1943 - Russia - Battle of Smolensk", url: "http://www.wikidata.org/entity/Q275019" }
  , { label: "01/01/1943 - Russia - Operation Carmen", url: "http://www.wikidata.org/entity/Q115193376" }
  , { label: "01/01/1943 - Socialist Federal Republic of Yugoslavia - Foibe massacres", url: "http://www.wikidata.org/entity/Q1294142" }
  , { label: "01/01/1943 - Soviet Union - Battle of Kursk", url: "http://www.wikidata.org/entity/Q130861" }
  , { label: "01/01/1943 - Soviet Union - Operation Concert", url: "http://www.wikidata.org/entity/Q675270" }
  , { label: "19/01/1943 - Unknown - Q136528042", url: "http://www.wikidata.org/entity/Q136528042" }
  , { label: "03/02/1943 - Russia - Malaya Zemlya", url: "http://www.wikidata.org/entity/Q2389861" }
  , { label: "09/02/1943 - Soviet Union - Battle of Krasny Bor", url: "http://www.wikidata.org/entity/Q2597597" }
  , { label: "18/02/1943 - Ukraine - Third Battle of Kharkov", url: "http://www.wikidata.org/entity/Q157873" }
  , { label: "24/02/1943 - Tunisia - Operation Ochsenkopf", url: "http://www.wikidata.org/entity/Q20203098" }
  , { label: "02/03/1943 - Unknown - Koriukivka massacre", url: "http://www.wikidata.org/entity/Q1527609" }
  , { label: "27/03/1943 - Unknown - Battle of Jelenov Žleb", url: "http://www.wikidata.org/entity/Q12785932" }
  , { label: "02/04/1943 - Unknown - Operation I-Go", url: "http://www.wikidata.org/entity/Q717561" }
  , { label: "03/04/1943 - Unknown - Q132449795", url: "http://www.wikidata.org/entity/Q132449795" }
  , { label: "06/04/1943 - Belgium - Q2380330", url: "http://www.wikidata.org/entity/Q2380330" }
  , { label: "17/04/1943 - Russia - Air Battle of Kuban", url: "http://www.wikidata.org/entity/Q4114772" }
  , { label: "22/04/1943 - Unknown - Battle of Bobdubi", url: "http://www.wikidata.org/entity/Q22115500" }
  , { label: "22/04/1943 - Unknown - Battle of Mubo", url: "http://www.wikidata.org/entity/Q22115503" }
  , { label: "26/04/1943 - Italy - bombing of Grosseto in World War II", url: "http://www.wikidata.org/entity/Q3641955" }
  , { label: "26/04/1943 - Slovenia - Battle of Golobar", url: "http://www.wikidata.org/entity/Q60839682" }
  , { label: "02/05/1943 - Unknown - Convoy TS 37", url: "http://www.wikidata.org/entity/Q17027846" }
  , { label: "03/05/1943 - Australia - Raid on Darwin", url: "http://www.wikidata.org/entity/Q1740133" }
  , { label: "04/05/1943 - Unknown - Operation Ramrod 16", url: "http://www.wikidata.org/entity/Q55627707" }
  , { label: "12/05/1943 - United States - Battle of Attu", url: "http://www.wikidata.org/entity/Q700572" }
  , { label: "14/05/1943 - Unknown - Convoy SC 129", url: "http://www.wikidata.org/entity/Q5166657" }
  , { label: "16/05/1943 - Unknown - Operation Checkmate", url: "http://www.wikidata.org/entity/Q7096887" }
  , { label: "17/05/1943 - Unknown - Operation Chastise", url: "http://www.wikidata.org/entity/Q845203" }
  , { label: "18/05/1943 - Unknown - Operation Maygewitter", url: "http://www.wikidata.org/entity/Q2140279" }
  , { label: "18/05/1943 - Unknown - Q131841097", url: "http://www.wikidata.org/entity/Q131841097" }
  , { label: "21/05/1943 - Unknown - Convoy SC 130", url: "http://www.wikidata.org/entity/Q5166658" }
  , { label: "21/05/1943 - Belarus - Operation Cottbus", url: "http://www.wikidata.org/entity/Q685521" }
  , { label: "06/06/1943 - Italy - Battle of Lampedusa", url: "http://www.wikidata.org/entity/Q2889088" }
  , { label: "08/06/1943 - Greece - Battle of Porta", url: "http://www.wikidata.org/entity/Q60524439" }
  , { label: "16/06/1943 - Unknown - Operation SE", url: "http://www.wikidata.org/entity/Q11349130" }
  , { label: "19/06/1943 - Unknown - Q102402494", url: "http://www.wikidata.org/entity/Q102402494" }
  , { label: "20/06/1943 - Unknown - New Georgia Campaign", url: "http://www.wikidata.org/entity/Q1970470" }
  , { label: "21/06/1943 - Greece - Battle of Sarantaporos", url: "http://www.wikidata.org/entity/Q115816255" }
  , { label: "23/06/1943 - Unknown - Battle of Lababia Ridge", url: "http://www.wikidata.org/entity/Q22115501" }
  , { label: "29/06/1943 - Unknown - Q132673706", url: "http://www.wikidata.org/entity/Q132673706" }
  , { label: "10/07/1943 - Italy - Allied invasion of Sicily", url: "http://www.wikidata.org/entity/Q217981" }
  , { label: "11/07/1943 - Unknown - Q132674124", url: "http://www.wikidata.org/entity/Q132674124" }
  , { label: "11/07/1943 - Italy - Battle of Gela", url: "http://www.wikidata.org/entity/Q980853" }
  , { label: "11/07/1943 - Italy - Italian Campaign", url: "http://www.wikidata.org/entity/Q162333" }
  , { label: "12/07/1943 - Unknown - Kisielin massacre", url: "http://www.wikidata.org/entity/Q6416698" }
  , { label: "13/07/1943 - Italy - Operation Chestnut", url: "http://www.wikidata.org/entity/Q3108630" }
  , { label: "13/07/1943 - Russia - Battle of Prokhorovka", url: "http://www.wikidata.org/entity/Q541506" }
  , { label: "15/07/1943 - Unknown - Battle of Makrynoros", url: "http://www.wikidata.org/entity/Q18342754" }
  , { label: "17/07/1943 - Unknown - Battle of Mount Tambu", url: "http://www.wikidata.org/entity/Q22115502" }
  , { label: "24/07/1943 - Netherlands - Wolfheze raid", url: "http://www.wikidata.org/entity/Q95422802" }
  , { label: "28/07/1943 - United States - Battle of the Pips", url: "http://www.wikidata.org/entity/Q4872991" }
  , { label: "01/08/1943 - Unknown - Belgorod–Kharkov offensive operation", url: "http://www.wikidata.org/entity/Q709484" }
  , { label: "02/08/1943 - Italy - Battle of Centuripe", url: "http://www.wikidata.org/entity/Q15894754" }
  , { label: "06/08/1943 - Unknown - Battle of Vella Gulf", url: "http://www.wikidata.org/entity/Q702142" }
  , { label: "11/08/1943 - Soviet Union - Operation Hermann", url: "http://www.wikidata.org/entity/Q24949081" }
  , { label: "14/08/1943 - Unknown - Battle of Roosevelt Ridge", url: "http://www.wikidata.org/entity/Q22115504" }
  , { label: "15/08/1943 - Unknown - Operation Cottage", url: "http://www.wikidata.org/entity/Q2033079" }
  , { label: "15/08/1943 - Greece - Battle of Trahili", url: "http://www.wikidata.org/entity/Q29530237" }
  , { label: "17/08/1943 - Germany - Schweinfurt–Regensburg mission", url: "http://www.wikidata.org/entity/Q575755" }
  , { label: "21/08/1943 - Unknown - Bombing of Wewak", url: "http://www.wikidata.org/entity/Q4940731" }
  , { label: "25/08/1943 - Unknown - Q131813249", url: "http://www.wikidata.org/entity/Q131813249" }
  , { label: "05/09/1943 - Papua New Guinea - Landing at Nadzab", url: "http://www.wikidata.org/entity/Q6484626" }
  , { label: "08/09/1943 - Unknown - Italian Liberation War", url: "http://www.wikidata.org/entity/Q3778681" }
  , { label: "08/09/1943 - Unknown - Operation Zitronella", url: "http://www.wikidata.org/entity/Q659436" }
  , { label: "09/09/1943 - Unknown - Operation Avalanche", url: "http://www.wikidata.org/entity/Q1447505" }
  , { label: "09/09/1943 - Greece - Battle of Arachov", url: "http://www.wikidata.org/entity/Q115991026" }
  , { label: "14/09/1943 - Slovenia - Battle of Turjak Castle", url: "http://www.wikidata.org/entity/Q4872607" }
  , { label: "15/09/1943 - Italy - Bombing of Avezzano", url: "http://www.wikidata.org/entity/Q62750948" }
  , { label: "16/09/1943 - Germany - Operation Garlic", url: "http://www.wikidata.org/entity/Q54945425" }
  , { label: "17/09/1943 - Italy - Allied invasion of Italy", url: "http://www.wikidata.org/entity/Q714777" }
  , { label: "18/09/1943 - Unknown - Finisterre Range campaign", url: "http://www.wikidata.org/entity/Q5450372" }
  , { label: "18/09/1943 - Italy - Aldriga massacre", url: "http://www.wikidata.org/entity/Q3718410" }
  , { label: "20/09/1943 - Greece - Massacre of the Acqui Division", url: "http://www.wikidata.org/entity/Q537576" }
  , { label: "21/09/1943 - Unknown - Operation Source", url: "http://www.wikidata.org/entity/Q2684105" }
  , { label: "21/09/1943 - Papua New Guinea - Battle of Finschhafen", url: "http://www.wikidata.org/entity/Q4871014" }
  , { label: "25/09/1943 - Soviet Union - Melitopol Offensive", url: "http://www.wikidata.org/entity/Q4289519" }
  , { label: "01/10/1943 - Unknown - Convoy SC 143", url: "http://www.wikidata.org/entity/Q5166659" }
  , { label: "03/10/1943 - Unknown - Operation Devon", url: "http://www.wikidata.org/entity/Q642460" }
  , { label: "06/10/1943 - Unknown - Land Battle of Vella Lavella", url: "http://www.wikidata.org/entity/Q2890307" }
  , { label: "13/10/1943 - Unknown - Battle of John's Knoll–Trevor's Ridge", url: "http://www.wikidata.org/entity/Q22115567" }
  , { label: "16/10/1943 - Unknown - Operation Duck Hunt", url: "http://www.wikidata.org/entity/Q119949819" }
  , { label: "18/10/1943 - Unknown - Convoys ONS 20/ON 206", url: "http://www.wikidata.org/entity/Q5166677" }
  , { label: "22/10/1943 - Unknown - Battle of Sept-Îles", url: "http://www.wikidata.org/entity/Q18330893" }
  , { label: "27/10/1943 - Unknown - Operation Candytuft", url: "http://www.wikidata.org/entity/Q3354671" }
  , { label: "29/10/1943 - Unknown - Convoy ON 207", url: "http://www.wikidata.org/entity/Q5166646" }
  , { label: "30/10/1943 - Italy - Bombing of Savona", url: "http://www.wikidata.org/entity/Q16156076" }
  , { label: "31/10/1943 - Unknown - Convoy SL 138/MKS 28", url: "http://www.wikidata.org/entity/Q5166666" }
  , { label: "31/10/1943 - Unknown - Q132065614", url: "http://www.wikidata.org/entity/Q132065614" }
  , { label: "01/11/1943 - Norway - Operation Goldfinch", url: "http://www.wikidata.org/entity/Q11993909" }
  , { label: "01/11/1943 - Papua New Guinea - Battle of Empress Augusta Bay", url: "http://www.wikidata.org/entity/Q2165486" }
  , { label: "01/11/1943 - Ukraine - Kerch–Eltigen Operation", url: "http://www.wikidata.org/entity/Q552727" }
  , { label: "05/11/1943 - Vatican City - Bombing of the Vatican", url: "http://www.wikidata.org/entity/Q2909620" }
  , { label: "08/11/1943 - Unknown - Oregon Maneuver", url: "http://www.wikidata.org/entity/Q16931457" }
  , { label: "12/11/1943 - Unknown - Action of 13 November 1943", url: "http://www.wikidata.org/entity/Q4677252" }
  , { label: "16/11/1943 - Norway - Operation Barbara", url: "http://www.wikidata.org/entity/Q21137573" }
  , { label: "19/11/1943 - Unknown - Battle of Tarawa", url: "http://www.wikidata.org/entity/Q250309" }
  , { label: "19/11/1943 - Norway - Operation Company", url: "http://www.wikidata.org/entity/Q19384590" }
  , { label: "20/11/1943 - Unknown - Battle of Abemama", url: "http://www.wikidata.org/entity/Q1497939" }
  , { label: "20/11/1943 - Unknown - Convoy SL 139/MKS 30", url: "http://www.wikidata.org/entity/Q5166667" }
  , { label: "24/11/1943 - Papua New Guinea - Battle of Cape St. George", url: "http://www.wikidata.org/entity/Q700530" }
  , { label: "25/11/1943 - Greece - Execution of the 118 at Monodendri", url: "http://www.wikidata.org/entity/Q19753353" }
  , { label: "28/11/1943 - Unknown - Convoy SL 140/MKS 31", url: "http://www.wikidata.org/entity/Q5166668" }
  , { label: "29/11/1943 - Unknown - Q105702912", url: "http://www.wikidata.org/entity/Q105702912" }
  , { label: "01/12/1943 - Bosnia and Herzegovina - Battle of Livno", url: "http://www.wikidata.org/entity/Q1564029" }
  , { label: "02/12/1943 - France - Bombing of Marseille", url: "http://www.wikidata.org/entity/Q134483882" }
  , { label: "05/12/1943 - Unknown - Battle of Sio", url: "http://www.wikidata.org/entity/Q4872384" }
  , { label: "08/12/1943 - Italy - Battle of San Pietro Infine", url: "http://www.wikidata.org/entity/Q4568436" }
  , { label: "08/12/1943 - Italy - bombardment of Porto Santo Stefano", url: "http://www.wikidata.org/entity/Q24941215" }
  , { label: "12/12/1943 - Slovenia - Battle of Kočevje", url: "http://www.wikidata.org/entity/Q4871490" }
  , { label: "15/12/1943 - Papua New Guinea - Operation Dexterity", url: "http://www.wikidata.org/entity/Q1726931" }
  , { label: "16/12/1943 - Italy - Bombing of Padua in World War II", url: "http://www.wikidata.org/entity/Q90581546" }
  , { label: "26/12/1943 - Norway - Battle of the North Cape", url: "http://www.wikidata.org/entity/Q715886" }
  , { label: "26/12/1943 - Papua New Guinea - Battle of Cape Gloucester", url: "http://www.wikidata.org/entity/Q3293566" }
  , { label: "27/12/1943 - Papua New Guinea - Battle of The Pimple", url: "http://www.wikidata.org/entity/Q4872538" }
  , { label: "01/01/1944 - Unknown - Action of 26 April 1944", url: "http://www.wikidata.org/entity/Q9172312" }
  , { label: "01/01/1944 - Unknown - Convoy Hi-71", url: "http://www.wikidata.org/entity/Q16842906" }
  , { label: "01/01/1944 - Unknown - Honchy Brid massacre", url: "http://www.wikidata.org/entity/Q74020478" }
  , { label: "01/01/1944 - Unknown - Lorraine Campaign", url: "http://www.wikidata.org/entity/Q2935372" }
  , { label: "01/01/1944 - Unknown - Operation Skye", url: "http://www.wikidata.org/entity/Q13420337" }
  , { label: "01/01/1944 - Unknown - Q132179382", url: "http://www.wikidata.org/entity/Q132179382" }
  , { label: "01/01/1944 - Unknown - Q132857918", url: "http://www.wikidata.org/entity/Q132857918" }
  , { label: "01/01/1944 - Unknown - Soviet Balkan campaign of 1944", url: "http://www.wikidata.org/entity/Q5742713" }
  , { label: "01/01/1944 - Belarus - Battle of Murowana Oszmianka", url: "http://www.wikidata.org/entity/Q4871829" }
  , { label: "01/01/1944 - Bosnia and Herzegovina - Raid on Drvar", url: "http://www.wikidata.org/entity/Q931125" }
  , { label: "01/01/1944 - Czech Republic - Životice tragedy", url: "http://www.wikidata.org/entity/Q3505714" }
  , { label: "01/01/1944 - India - Battle of Kohima", url: "http://www.wikidata.org/entity/Q383614" }
  , { label: "01/01/1944 - Italy - Operation Baobab", url: "http://www.wikidata.org/entity/Q3354643" }
  , { label: "01/01/1944 - Kingdom of Romania - Bombing of Brasov in WW2", url: "http://www.wikidata.org/entity/Q136472839" }
  , { label: "01/01/1944 - Kingdom of Romania - Bombing of Timisoara in WW2", url: "http://www.wikidata.org/entity/Q128792690" }
  , { label: "01/01/1944 - Netherlands - Q121432676", url: "http://www.wikidata.org/entity/Q121432676" }
  , { label: "01/01/1944 - Netherlands - reprisals at Herbaijum and Menaldum", url: "http://www.wikidata.org/entity/Q76365368" }
  , { label: "01/01/1944 - Poland - Battle of Ceber", url: "http://www.wikidata.org/entity/Q4870681" }
  , { label: "01/01/1944 - Romania - Battle of Romania", url: "http://www.wikidata.org/entity/Q4859251" }
  , { label: "01/01/1944 - Romania - Southern Transylvania Campaign (1944)", url: "http://www.wikidata.org/entity/Q912946" }
  , { label: "01/01/1944 - Romania - bombing of Bucharest in World War II", url: "http://www.wikidata.org/entity/Q2042421" }
  , { label: "01/01/1944 - Sweden - refugee's boats to Sweden", url: "http://www.wikidata.org/entity/Q50378624" }
  , { label: "02/01/1944 - Italy - Valibona", url: "http://www.wikidata.org/entity/Q3636650" }
  , { label: "03/01/1944 - Unknown - Operation Tempest", url: "http://www.wikidata.org/entity/Q422376" }
  , { label: "11/01/1944 - Unknown - Operation Pomegranate", url: "http://www.wikidata.org/entity/Q7097406" }
  , { label: "18/01/1944 - Papua New Guinea - Battle of Crater Hill", url: "http://www.wikidata.org/entity/Q4870804" }
  , { label: "30/01/1944 - France - Maquis des Glières", url: "http://www.wikidata.org/entity/Q931676" }
  , { label: "13/02/1944 - Unknown - Action of 14 February 1944", url: "http://www.wikidata.org/entity/Q4677257" }
  , { label: "16/02/1944 - Unknown - Operation Hailstone", url: "http://www.wikidata.org/entity/Q2026138" }
  , { label: "16/02/1944 - United States - Battle of Eniwetok", url: "http://www.wikidata.org/entity/Q1935947" }
  , { label: "17/02/1944 - Unknown - Battle of Karavia Bay", url: "http://www.wikidata.org/entity/Q4871386" }
  , { label: "17/02/1944 - Unknown - Operation Jericho", url: "http://www.wikidata.org/entity/Q2916956" }
  , { label: "19/02/1944 - Unknown - Big Week", url: "http://www.wikidata.org/entity/Q317295" }
  , { label: "21/02/1944 - Netherlands - Bombing of Nijmegen", url: "http://www.wikidata.org/entity/Q2229399" }
  , { label: "26/02/1944 - Ukraine - Battle of Kovel", url: "http://www.wikidata.org/entity/Q137714644" }
  , { label: "02/03/1944 - Unknown - Hrubieszów revolution", url: "http://www.wikidata.org/entity/Q30957231" }
  , { label: "09/03/1944 - Unknown - Battle of Talasea", url: "http://www.wikidata.org/entity/Q23751276" }
  , { label: "25/03/1944 - Poland - Skirmish near Sadkówka", url: "http://www.wikidata.org/entity/Q24945173" }
  , { label: "27/03/1944 - France - Biarritz Bombing", url: "http://www.wikidata.org/entity/Q16516605" }
  , { label: "30/03/1944 - Unknown - Operation Desecrate One", url: "http://www.wikidata.org/entity/Q2026043" }
  , { label: "01/04/1944 - Unknown - Battle of Madang", url: "http://www.wikidata.org/entity/Q22947516" }
  , { label: "01/04/1944 - Unknown - Bombing of Schaffhausen", url: "http://www.wikidata.org/entity/Q2880659" }
  , { label: "01/04/1944 - Soviet Union - Battle of Ternopil", url: "http://www.wikidata.org/entity/Q121251728" }
  , { label: "03/04/1944 - Unknown - Operation Tungsten", url: "http://www.wikidata.org/entity/Q3354882" }
  , { label: "05/04/1944 - Greece - Kleisoura massacre 1944", url: "http://www.wikidata.org/entity/Q31284270" }
  , { label: "07/04/1944 - Unknown - Air strike on Darnitsa", url: "http://www.wikidata.org/entity/Q9370605" }
  , { label: "13/04/1944 - Kingdom of Italy - Vallucciole massacre", url: "http://www.wikidata.org/entity/Q63392172" }
  , { label: "18/04/1944 - France - Q17622166", url: "http://www.wikidata.org/entity/Q17622166" }
  , { label: "25/04/1944 - France - Battle of 25 April 1944", url: "http://www.wikidata.org/entity/Q16701434" }
  , { label: "25/04/1944 - Greece - Karakolithos hostage executions", url: "http://www.wikidata.org/entity/Q19670113" }
  , { label: "28/04/1944 - Unknown - Exercise Tiger", url: "http://www.wikidata.org/entity/Q2748496" }
  , { label: "30/04/1944 - Croatia - Lipa massacre", url: "http://www.wikidata.org/entity/Q63351598" }
  , { label: "14/05/1944 - Unknown - Bombing of Pescara in World War II", url: "http://www.wikidata.org/entity/Q3641958" }
  , { label: "21/05/1944 - Indonesia - Battle of Wakde", url: "http://www.wikidata.org/entity/Q4872707" }
  , { label: "21/05/1944 - Italy - Operation Diadem", url: "http://www.wikidata.org/entity/Q7096986" }
  , { label: "25/05/1944 - Soviet Union - Operation Cormorant", url: "http://www.wikidata.org/entity/Q12136066" }
  , { label: "27/05/1944 - Indonesia - Battle of Biak", url: "http://www.wikidata.org/entity/Q712181" }
  , { label: "28/05/1944 - Belgium - crash at Brandven Hoogstraten 1944", url: "http://www.wikidata.org/entity/Q130616591" }
  , { label: "01/06/1944 - France - Battle of Mont Mouchet", url: "http://www.wikidata.org/entity/Q2890796" }
  , { label: "02/06/1944 - Kingdom of Hungary - Bombing of Cluj in WW2", url: "http://www.wikidata.org/entity/Q28722628" }
  , { label: "02/06/1944 - Kingdom of Hungary - Bombing of Miskolc", url: "http://www.wikidata.org/entity/Q21900262" }
  , { label: "04/06/1944 - Unknown - Liberation of Rome", url: "http://www.wikidata.org/entity/Q3831648" }
  , { label: "09/06/1944 - Unknown - Battle in the Janow Forest", url: "http://www.wikidata.org/entity/Q9347510" }
  , { label: "11/06/1944 - France - Battle of Le Mesnil-Patry", url: "http://www.wikidata.org/entity/Q714200" }
  , { label: "13/06/1944 - Unknown - Q131697326", url: "http://www.wikidata.org/entity/Q131697326" }
  , { label: "13/06/1944 - France - Battle of Villers-Bocage", url: "http://www.wikidata.org/entity/Q700710" }
  , { label: "20/06/1944 - France - Battle of la Truyère", url: "http://www.wikidata.org/entity/Q88849674" }
  , { label: "02/07/1944 - Italy - Battle of Ancona", url: "http://www.wikidata.org/entity/Q714192" }
  , { label: "02/07/1944 - Italy - Battle of Filottrano", url: "http://www.wikidata.org/entity/Q3636433" }
  , { label: "02/07/1944 - Nazi Germany - Battle of Krynki", url: "http://www.wikidata.org/entity/Q135274359" }
  , { label: "02/07/1944 - Unknown - Battle of Noemfoor", url: "http://www.wikidata.org/entity/Q4871905" }
  , { label: "03/07/1944 - Unknown - Q4090462", url: "http://www.wikidata.org/entity/Q4090462" }
  , { label: "05/07/1944 - Unknown - Battle of Pierres Noires", url: "http://www.wikidata.org/entity/Q4872038" }
  , { label: "06/07/1944 - France - Battle of Roquefixade", url: "http://www.wikidata.org/entity/Q99238349" }
  , { label: "07/07/1944 - Lithuania - Operation Ostra Brama", url: "http://www.wikidata.org/entity/Q719515" }
  , { label: "10/07/1944 - Soviet Union - Rezekne-Daugavpils offensive", url: "http://www.wikidata.org/entity/Q4392332" }
  , { label: "11/07/1944 - France - Battle of Foret de Mont Castre", url: "http://www.wikidata.org/entity/Q87769103" }
  , { label: "12/07/1944 - Greece - Battle of Amfilochia", url: "http://www.wikidata.org/entity/Q16245759" }
  , { label: "14/07/1944 - Unknown - Battle of Haye-du-Puits", url: "http://www.wikidata.org/entity/Q2889051" }
  , { label: "17/07/1944 - Unknown - Action of 17 July 1944", url: "http://www.wikidata.org/entity/Q4677274" }
  , { label: "17/07/1944 - Unknown - Operation Mascot", url: "http://www.wikidata.org/entity/Q15264166" }
  , { label: "18/07/1944 - France - Battle of Mount Gargan", url: "http://www.wikidata.org/entity/Q2890791" }
  , { label: "19/07/1944 - France - Battle of Verrières Ridge", url: "http://www.wikidata.org/entity/Q2890620" }
  , { label: "20/07/1944 - Poland - 20 July plot", url: "http://www.wikidata.org/entity/Q105570" }
  , { label: "23/07/1944 - Ukraine - Lwów Uprising", url: "http://www.wikidata.org/entity/Q718839" }
  , { label: "24/07/1944 - Unknown - Guerre des Haies", url: "http://www.wikidata.org/entity/Q2890669" }
  , { label: "24/07/1944 - France - Battle of Saint-Lô", url: "http://www.wikidata.org/entity/Q2237217" }
  , { label: "25/07/1944 - Unknown - Operation Cobra", url: "http://www.wikidata.org/entity/Q700674" }
  , { label: "25/07/1944 - Italy - Battle of Montecarotto", url: "http://www.wikidata.org/entity/Q3636536" }
  , { label: "27/07/1944 - Latvia - Battle of Daugavpils", url: "http://www.wikidata.org/entity/Q131119528" }
  , { label: "30/07/1944 - Latvia - Battle of Jelgava", url: "http://www.wikidata.org/entity/Q65297426" }
  , { label: "31/07/1944 - Poland - Battle of Młodzawy", url: "http://www.wikidata.org/entity/Q20034940" }
  , { label: "01/08/1944 - Unknown - Thunderclap plan", url: "http://www.wikidata.org/entity/Q2026451" }
  , { label: "01/08/1944 - France - Lorient pocket", url: "http://www.wikidata.org/entity/Q3392943" }
  , { label: "02/08/1944 - France - Valmanya massacre", url: "http://www.wikidata.org/entity/Q11936124" }
  , { label: "02/08/1944 - Poland - Battle of Pęcice", url: "http://www.wikidata.org/entity/Q549305" }
  , { label: "05/08/1944 - Poland - Battle of Jaksicami", url: "http://www.wikidata.org/entity/Q20034938" }
  , { label: "05/08/1944 - Poland - Battle of Skalbmierz", url: "http://www.wikidata.org/entity/Q20034837" }
  , { label: "09/08/1944 - Unknown - Battle for Hill 140", url: "http://www.wikidata.org/entity/Q9172673" }
  , { label: "10/08/1944 - United States - Battle of Guam", url: "http://www.wikidata.org/entity/Q696900" }
  , { label: "11/08/1944 - Unknown - Battle of Val Orco", url: "http://www.wikidata.org/entity/Q11156567" }
  , { label: "12/08/1944 - France - Operation Loyton", url: "http://www.wikidata.org/entity/Q2026177" }
  , { label: "12/08/1944 - Kingdom of Hungary - Bombing of Hajdúböszörmény in the WWII", url: "http://www.wikidata.org/entity/Q21182913" }
  , { label: "13/08/1944 - France - Operation Lüttich", url: "http://www.wikidata.org/entity/Q698220" }
  , { label: "14/08/1944 - Poland - Skirmish near Baranów", url: "http://www.wikidata.org/entity/Q20035078" }
  , { label: "17/08/1944 - Greece - Executions of Kokkinia", url: "http://www.wikidata.org/entity/Q12881325" }
  , { label: "18/08/1944 - France - Battle of Chambois", url: "http://www.wikidata.org/entity/Q4870705" }
  , { label: "20/08/1944 - Unknown - Warsaw Insurgent attacks on the Gdańska Railway Station", url: "http://www.wikidata.org/entity/Q11826034" }
  , { label: "20/08/1944 - France - Liberation of Martigues", url: "http://www.wikidata.org/entity/Q13622762" }
  , { label: "21/08/1944 - France - Battle of Marseille", url: "http://www.wikidata.org/entity/Q2889272" }
  , { label: "21/08/1944 - France - Battle of Montélimar", url: "http://www.wikidata.org/entity/Q2889388" }
  , { label: "22/08/1944 - France - Operation Madelaine", url: "http://www.wikidata.org/entity/Q110163618" }
  , { label: "24/08/1944 - Romania - Q130282485", url: "http://www.wikidata.org/entity/Q130282485" }
  , { label: "28/08/1944 - France - Battle of Nice", url: "http://www.wikidata.org/entity/Q3237998" }
  , { label: "29/08/1944 - Unknown - Operation Goodwood", url: "http://www.wikidata.org/entity/Q17513584" }
  , { label: "31/08/1944 - Unknown - Battle of Sansapor", url: "http://www.wikidata.org/entity/Q4872297" }
  , { label: "31/08/1944 - France - Battle of Meximieux", url: "http://www.wikidata.org/entity/Q15816796" }
  , { label: "01/09/1944 - Unknown - Operation Nordlicht", url: "http://www.wikidata.org/entity/Q12007951" }
  , { label: "01/09/1944 - France - Allied Siege of La Rochelle", url: "http://www.wikidata.org/entity/Q3392944" }
  , { label: "01/09/1944 - France - Operation Waldfest", url: "http://www.wikidata.org/entity/Q60751274" }
  , { label: "01/09/1944 - Belgium - Liberation of Belgium", url: "http://www.wikidata.org/entity/Q19429045" }
  , { label: "02/09/1944 - France - Liberation of Lyon", url: "http://www.wikidata.org/entity/Q63350866" }
  , { label: "03/09/1944 - Belgium - Battle of Merksem", url: "http://www.wikidata.org/entity/Q101628069" }
  , { label: "04/09/1944 - Unknown - Soviet-Bulgarian War", url: "http://www.wikidata.org/entity/Q573472" }
  , { label: "04/09/1944 - France - Battle of Nancy", url: "http://www.wikidata.org/entity/Q767510" }
  , { label: "05/09/1944 - Unknown - Battle of Telgárt", url: "http://www.wikidata.org/entity/Q24877272" }
  , { label: "06/09/1944 - Philippines - Shinyo Maru Incident", url: "http://www.wikidata.org/entity/Q7497841" }
  , { label: "07/09/1944 - Belgium - Battle of Helchteren", url: "http://www.wikidata.org/entity/Q131410545" }
  , { label: "10/09/1944 - Unknown - Air battle over the Ore Mountains", url: "http://www.wikidata.org/entity/Q1875790" }
  , { label: "11/09/1944 - France - Royan pocket", url: "http://www.wikidata.org/entity/Q15780993" }
  , { label: "11/09/1944 - Italy - Battle of Gravellona Toce", url: "http://www.wikidata.org/entity/Q28668006" }
  , { label: "13/09/1944 - Germany - Battle of Hürtgen Forest", url: "http://www.wikidata.org/entity/Q162287" }
  , { label: "14/09/1944 - Unknown - Operation Paravane", url: "http://www.wikidata.org/entity/Q7097375" }
  , { label: "14/09/1944 - Finland - Lapland War", url: "http://www.wikidata.org/entity/Q154940" }
  , { label: "15/09/1944 - Netherlands - liberation of Colmont", url: "http://www.wikidata.org/entity/Q2529146" }
  , { label: "16/09/1944 - Unknown - Surrender of General Botho Elster", url: "http://www.wikidata.org/entity/Q3422842" }
  , { label: "17/09/1944 - Unknown - Allied bombing of Belgrade (1944)", url: "http://www.wikidata.org/entity/Q9645147" }
  , { label: "17/09/1944 - France - Battle of Arracourt", url: "http://www.wikidata.org/entity/Q2887891" }
  , { label: "19/09/1944 - Netherlands - Q81380171", url: "http://www.wikidata.org/entity/Q81380171" }
  , { label: "20/09/1944 - Estonia - Battle of Porkuni", url: "http://www.wikidata.org/entity/Q4872082" }
  , { label: "23/09/1944 - Unknown - Hărcana massacre", url: "http://www.wikidata.org/entity/Q12735117" }
  , { label: "29/09/1944 - Italy - San Giacomo masacre", url: "http://www.wikidata.org/entity/Q29653393" }
  , { label: "29/09/1944 - Netherlands - Battle of Overloon", url: "http://www.wikidata.org/entity/Q1332237" }
  , { label: "01/10/1944 - Unknown - Operation Big Ben", url: "http://www.wikidata.org/entity/Q29075175" }
  , { label: "01/10/1944 - Netherlands - The Tielcase", url: "http://www.wikidata.org/entity/Q109672220" }
  , { label: "01/10/1944 - Norway - Liberation of East Finnmark", url: "http://www.wikidata.org/entity/Q23042891" }
  , { label: "02/10/1944 - Belgium - Battle of the Scheldt", url: "http://www.wikidata.org/entity/Q697022" }
  , { label: "02/10/1944 - Germany - Battle of Aachen", url: "http://www.wikidata.org/entity/Q327052" }
  , { label: "02/10/1944 - Germany - Battle of Übach – Palenberg", url: "http://www.wikidata.org/entity/Q60732719" }
  , { label: "02/10/1944 - Poland - Warsaw Uprising", url: "http://www.wikidata.org/entity/Q1402078" }
  , { label: "07/10/1944 - Norway - Petsamo–Kirkenes Offensive", url: "http://www.wikidata.org/entity/Q705222" }
  , { label: "08/10/1944 - Estonia - Battle of Tehumardi", url: "http://www.wikidata.org/entity/Q2065459" }
  , { label: "08/10/1944 - Germany - Battle of Crucifix Hill", url: "http://www.wikidata.org/entity/Q4870811" }
  , { label: "08/10/1944 - Netherlands - church razzia in the Netherlands", url: "http://www.wikidata.org/entity/Q23935163" }
  , { label: "09/10/1944 - Italy - Battle of Purocielo", url: "http://www.wikidata.org/entity/Q108180729" }
  , { label: "09/10/1944 - Latvia - Courland Pocket", url: "http://www.wikidata.org/entity/Q697172" }
  , { label: "10/10/1944 - Unknown - Ruda Różaniecka massacre", url: "http://www.wikidata.org/entity/Q9388668" }
  , { label: "12/10/1944 - Unknown - Q104599682", url: "http://www.wikidata.org/entity/Q104599682" }
  , { label: "14/10/1944 - Unknown - Moisei massacre", url: "http://www.wikidata.org/entity/Q12735118" }
  , { label: "15/10/1944 - Unknown - Battle of Vukov Klanac", url: "http://www.wikidata.org/entity/Q24629808" }
  , { label: "15/10/1944 - Nazi Germany - Bombing of Braunschweig in World War II", url: "http://www.wikidata.org/entity/Q877137" }
  , { label: "21/10/1944 - Romania - Battle of Carei", url: "http://www.wikidata.org/entity/Q23747405" }
  , { label: "22/10/1944 - Netherlands - Q77579808", url: "http://www.wikidata.org/entity/Q77579808" }
  , { label: "23/10/1944 - Unknown - Battle of Leyte Gulf", url: "http://www.wikidata.org/entity/Q308999" }
  , { label: "23/10/1944 - Belgium - Q130705410", url: "http://www.wikidata.org/entity/Q130705410" }
  , { label: "24/10/1944 - France - Lost Battalion", url: "http://www.wikidata.org/entity/Q2890698" }
  , { label: "28/10/1944 - Unknown - Slovak National Uprising", url: "http://www.wikidata.org/entity/Q163780" }
  , { label: "29/10/1944 - Norway - Operation Obviate", url: "http://www.wikidata.org/entity/Q7097348" }
  , { label: "30/10/1944 - France - Bataille de Bruyères", url: "http://www.wikidata.org/entity/Q2888205" }
  , { label: "30/10/1944 - Greece - Q126500902", url: "http://www.wikidata.org/entity/Q126500902" }
  , { label: "31/10/1944 - Unknown - Aarhus Air Raid", url: "http://www.wikidata.org/entity/Q12325070" }
  , { label: "31/10/1944 - Papua New Guinea - Aitape–Wewak campaign", url: "http://www.wikidata.org/entity/Q15914063" }
  , { label: "06/11/1944 - Kingdom of Italy - Battle of Porta Lame", url: "http://www.wikidata.org/entity/Q3636581" }
  , { label: "06/11/1944 - Serbia - Niš incident", url: "http://www.wikidata.org/entity/Q4698295" }
  , { label: "09/11/1944 - Unknown - Action of 10 November 1944", url: "http://www.wikidata.org/entity/Q4677230" }
  , { label: "09/11/1944 - Germany - Operation Clipper", url: "http://www.wikidata.org/entity/Q835874" }
  , { label: "13/11/1944 - Unknown - Q21029353", url: "http://www.wikidata.org/entity/Q21029353" }
  , { label: "15/11/1944 - Protectorate of Bohemia and Moravia - Operation Grouse", url: "http://www.wikidata.org/entity/Q11156095" }
  , { label: "16/11/1944 - Kingdom of Italy - Caffè del Doro massacre", url: "http://www.wikidata.org/entity/Q24934679" }
  , { label: "19/11/1944 - Unknown - Battle of Alsace", url: "http://www.wikidata.org/entity/Q24935999" }
  , { label: "22/11/1944 - France - Liberation of Strasbourg", url: "http://www.wikidata.org/entity/Q65129037" }
  , { label: "24/11/1944 - Nazi Germany - Q116390623", url: "http://www.wikidata.org/entity/Q116390623" }
  , { label: "01/12/1944 - Unknown - Battle of Wide Bay", url: "http://www.wikidata.org/entity/Q4872734" }
  , { label: "01/12/1944 - Unknown - Operation Safehaven", url: "http://www.wikidata.org/entity/Q16919720" }
  , { label: "03/12/1944 - Greece - Dekemvriana", url: "http://www.wikidata.org/entity/Q1473722" }
  , { label: "04/12/1944 - Netherlands - Battle of Haalderen", url: "http://www.wikidata.org/entity/Q121432701" }
  , { label: "13/12/1944 - Kingdom of Italy - Q63339715", url: "http://www.wikidata.org/entity/Q63339715" }
  , { label: "15/12/1944 - Unknown - 1940–1944 insurgency in Chechnya", url: "http://www.wikidata.org/entity/Q714706" }
  , { label: "16/12/1944 - Unknown - Battle of Kesternich", url: "http://www.wikidata.org/entity/Q15197283" }
  , { label: "16/12/1944 - Unknown - Operation Queen", url: "http://www.wikidata.org/entity/Q885019" }
  , { label: "16/12/1944 - Belgium - Operation Greif", url: "http://www.wikidata.org/entity/Q167002" }
  , { label: "17/12/1944 - Protectorate of Bohemia and Moravia - Bloody Sunday", url: "http://www.wikidata.org/entity/Q79080907" }
  , { label: "21/12/1944 - Unknown - Q36941622", url: "http://www.wikidata.org/entity/Q36941622" }
  , { label: "24/12/1944 - Hungary - Siege of Budapest", url: "http://www.wikidata.org/entity/Q155103" }
  , { label: "26/12/1944 - Unknown - Battle of Heartbreak Crossroads", url: "http://www.wikidata.org/entity/Q20744051" }
  , { label: "26/12/1944 - Belgium - Elsenborn Ridge", url: "http://www.wikidata.org/entity/Q3535104" }
  , { label: "01/01/1945 - Unknown - Battle of Point Judith", url: "http://www.wikidata.org/entity/Q4872070" }
  , { label: "01/01/1945 - Unknown - Capture of Tilsit in 1945", url: "http://www.wikidata.org/entity/Q15808569" }
  , { label: "01/01/1945 - Unknown - Final operations in Slovenia", url: "http://www.wikidata.org/entity/Q2889635" }
  , { label: "01/01/1945 - Unknown - Operation Blacklist", url: "http://www.wikidata.org/entity/Q139379139" }
  , { label: "01/01/1945 - Unknown - Operation Blacklist Forty", url: "http://www.wikidata.org/entity/Q16204244" }
  , { label: "01/01/1945 - Unknown - Q1730342", url: "http://www.wikidata.org/entity/Q1730342" }
  , { label: "01/01/1945 - Belgium - Operation Bodenplatte", url: "http://www.wikidata.org/entity/Q835881" }
  , { label: "01/01/1945 - Czech Republic - May Uprising of the Czech people", url: "http://www.wikidata.org/entity/Q9974702" }
  , { label: "01/01/1945 - Czechoslovakia - liberation of Czechoslovakia", url: "http://www.wikidata.org/entity/Q32041346" }
  , { label: "01/01/1945 - Germany - Battle of Aschaffenburg", url: "http://www.wikidata.org/entity/Q96373237" }
  , { label: "01/01/1945 - Germany - Battle of Bautzen", url: "http://www.wikidata.org/entity/Q316843" }
  , { label: "01/01/1945 - Japan - Battle of Okinawa", url: "http://www.wikidata.org/entity/Q192660" }
  , { label: "01/01/1945 - Kingdom of Italy - Battle of Mortirolo", url: "http://www.wikidata.org/entity/Q3636687" }
  , { label: "01/01/1945 - Nazi Germany - Metgethen massacre", url: "http://www.wikidata.org/entity/Q477332" }
  , { label: "01/01/1945 - Netherlands - Battle of Groningen", url: "http://www.wikidata.org/entity/Q2234138" }
  , { label: "01/01/1945 - Netherlands - Operation Zetten", url: "http://www.wikidata.org/entity/Q121432695" }
  , { label: "01/01/1945 - Philippines - Battle of Manila", url: "http://www.wikidata.org/entity/Q696931" }
  , { label: "01/01/1945 - Poland - Battle of Bydgoszcz", url: "http://www.wikidata.org/entity/Q131139926" }
  , { label: "01/01/1945 - Poland - Miejsce upadku samolotu pod Wróblikiem", url: "http://www.wikidata.org/entity/Q99134835" }
  , { label: "12/01/1945 - Unknown - East Prussian Offensive", url: "http://www.wikidata.org/entity/Q636087" }
  , { label: "14/01/1945 - Unknown - Battle of Jasło", url: "http://www.wikidata.org/entity/Q11155489" }
  , { label: "16/01/1945 - Yugoslavia - Q106692588", url: "http://www.wikidata.org/entity/Q106692588" }
  , { label: "18/01/1945 - Poland - Battle of Koło", url: "http://www.wikidata.org/entity/Q114840683" }
  , { label: "18/01/1945 - Poland - Liberation of Łódź", url: "http://www.wikidata.org/entity/Q9380570" }
  , { label: "21/01/1945 - Poland - Battle of Opole", url: "http://www.wikidata.org/entity/Q11688153" }
  , { label: "23/01/1945 - Poland - Battle of Poznań", url: "http://www.wikidata.org/entity/Q821041" }
  , { label: "25/01/1945 - Netherlands - Battle for the Kapelsche Veer", url: "http://www.wikidata.org/entity/Q2236703" }
  , { label: "26/01/1945 - Unknown - Q2679104", url: "http://www.wikidata.org/entity/Q2679104" }
  , { label: "26/01/1945 - Poland - Battle of Żory (1945)", url: "http://www.wikidata.org/entity/Q9173830" }
  , { label: "29/01/1945 - Philippines - Raid at Cabanatuan", url: "http://www.wikidata.org/entity/Q705083" }
  , { label: "30/01/1945 - Philippines - Battle of Bataan", url: "http://www.wikidata.org/entity/Q702449" }
  , { label: "07/02/1945 - Germany - Operation Veritable", url: "http://www.wikidata.org/entity/Q708235" }
  , { label: "07/02/1945 - Nazi Germany - Devyataev's group escape", url: "http://www.wikidata.org/entity/Q4366133" }
  , { label: "08/02/1945 - France - Colmar Pocket", url: "http://www.wikidata.org/entity/Q708253" }
  , { label: "08/02/1945 - Norway - Black Friday", url: "http://www.wikidata.org/entity/Q2748375" }
  , { label: "10/02/1945 - Poland - Siege of Glogau", url: "http://www.wikidata.org/entity/Q815141" }
  , { label: "17/02/1945 - Italy - Battle of Riva Ridge", url: "http://www.wikidata.org/entity/Q3883998" }
  , { label: "19/02/1945 - Unknown - Q136688481", url: "http://www.wikidata.org/entity/Q136688481" }
  , { label: "21/02/1945 - Nazi Germany - Luftangriff auf Wallhausen", url: "http://www.wikidata.org/entity/Q48757272" }
  , { label: "22/02/1945 - Japanese occupation of the Philippines - Raid on Los Baños", url: "http://www.wikidata.org/entity/Q7283721" }
  , { label: "22/02/1945 - Unknown - Lower Silesian Offensive", url: "http://www.wikidata.org/entity/Q636363" }
  , { label: "24/02/1945 - Unknown - Battle of Corregidor", url: "http://www.wikidata.org/entity/Q702568" }
  , { label: "02/03/1945 - Poland - Battle of Schoenfeld", url: "http://www.wikidata.org/entity/Q4872333" }
  , { label: "04/03/1945 - German Reich - 1945 Greven Avro Lancaster Mk.III ME453 shootdown", url: "http://www.wikidata.org/entity/Q138498632" }
  , { label: "04/03/1945 - Netherlands - Bombing of the Bezuidenhout", url: "http://www.wikidata.org/entity/Q2912379" }
  , { label: "04/03/1945 - Poland - Pawłokoma massacre", url: "http://www.wikidata.org/entity/Q1966827" }
  , { label: "07/03/1945 - Unknown - Battle of the Transdanubian Hills", url: "http://www.wikidata.org/entity/Q4873030" }
  , { label: "18/03/1945 - Netherlands - reprisal at Doniaga", url: "http://www.wikidata.org/entity/Q90044944" }
  , { label: "18/03/1945 - Poland - Battle of Prudnik", url: "http://www.wikidata.org/entity/Q57452634" }
  , { label: "22/03/1945 - Denmark - Operation Carthage", url: "http://www.wikidata.org/entity/Q1810832" }
  , { label: "27/03/1945 - Czech Republic - The Long Fight", url: "http://www.wikidata.org/entity/Q11222701" }
  , { label: "01/04/1945 - Unknown - Upper Silesian Offensive", url: "http://www.wikidata.org/entity/Q678537" }
  , { label: "02/04/1945 - Unknown - Operation Teardrop", url: "http://www.wikidata.org/entity/Q1573520" }
  , { label: "02/04/1945 - Germany - Battle of Königshofen", url: "http://www.wikidata.org/entity/Q99455352" }
  , { label: "02/04/1945 - Italy - Bombing of Turin in World War II", url: "http://www.wikidata.org/entity/Q85366027" }
  , { label: "02/04/1945 - Netherlands - Q121432672", url: "http://www.wikidata.org/entity/Q121432672" }
  , { label: "05/04/1945 - Germany - Battle of Heilbronn", url: "http://www.wikidata.org/entity/Q245890" }
  , { label: "07/04/1945 - Russia - Battle of Königsberg", url: "http://www.wikidata.org/entity/Q671528" }
  , { label: "12/04/1945 - Unknown - Brzuska Massacre", url: "http://www.wikidata.org/entity/Q8875447" }
  , { label: "12/04/1945 - Unknown - Operation Copper", url: "http://www.wikidata.org/entity/Q16960622" }
  , { label: "12/04/1945 - Unknown - Sivchyn massacre", url: "http://www.wikidata.org/entity/Q8875501" }
  , { label: "14/04/1945 - Poland - Battle of Mołomotkami", url: "http://www.wikidata.org/entity/Q136445094" }
  , { label: "15/04/1945 - Germany - Bombing of Potsdam", url: "http://www.wikidata.org/entity/Q1536074" }
  , { label: "15/04/1945 - Kingdom of Hungary - Operation Spring Awakening", url: "http://www.wikidata.org/entity/Q155995" }
  , { label: "16/04/1945 - Germany - Battle of the Seelow Heights", url: "http://www.wikidata.org/entity/Q7879625" }
  , { label: "18/04/1945 - Germany - Battle for Merkendorf", url: "http://www.wikidata.org/entity/Q15822566" }
  , { label: "18/04/1945 - Norway - Q19384591", url: "http://www.wikidata.org/entity/Q19384591" }
  , { label: "19/04/1945 - Bosnia and Herzegovina - Battle of Odžak", url: "http://www.wikidata.org/entity/Q3501165" }
  , { label: "23/04/1945 - Unknown - Race to Berlin", url: "http://www.wikidata.org/entity/Q7278971" }
  , { label: "24/04/1945 - Unknown - Battle of Halbe", url: "http://www.wikidata.org/entity/Q282438" }
  , { label: "25/04/1945 - Unknown - Bombing of Obersalzberg", url: "http://www.wikidata.org/entity/Q71715134" }
  , { label: "26/04/1945 - Italy - Liberation of Vercelli", url: "http://www.wikidata.org/entity/Q113248387" }
  , { label: "26/04/1945 - Italy - San Bernardo massacre", url: "http://www.wikidata.org/entity/Q107096378" }
  , { label: "26/04/1945 - Norway - Battle of Haglebu", url: "http://www.wikidata.org/entity/Q17779736" }
  , { label: "28/04/1945 - Czech Republic - Operation Cowboy", url: "http://www.wikidata.org/entity/Q110517047" }
  , { label: "29/04/1945 - Unknown - Operations Manna and Chowhound", url: "http://www.wikidata.org/entity/Q2471567" }
  , { label: "29/04/1945 - Italy - Battle of Opicina", url: "http://www.wikidata.org/entity/Q28670055" }
  , { label: "02/05/1945 - Czech Republic - Přerov Uprising", url: "http://www.wikidata.org/entity/Q12048057" }
  , { label: "02/05/1945 - Protectorate of Bohemia and Moravia - Q19941972", url: "http://www.wikidata.org/entity/Q19941972" }
  , { label: "06/05/1945 - Austria - Battle of Castle Itter", url: "http://www.wikidata.org/entity/Q14303815" }
  , { label: "07/05/1945 - Unknown - Prague offensive", url: "http://www.wikidata.org/entity/Q157445" }
  , { label: "08/05/1945 - Unknown - German Instrument of Surrender", url: "http://www.wikidata.org/entity/Q700983" }
  , { label: "08/05/1945 - Czech Republic - Battle of Břest", url: "http://www.wikidata.org/entity/Q11153820" }
  , { label: "08/05/1945 - Poland - Battle of Kuryłówka", url: "http://www.wikidata.org/entity/Q1497922" }
  , { label: "10/05/1945 - Unknown - Operation Doomsday", url: "http://www.wikidata.org/entity/Q7096999" }
  , { label: "12/05/1945 - Unknown - Battle of Slivice", url: "http://www.wikidata.org/entity/Q276852" }
  , { label: "20/05/1945 - Philippines - Battle of Ipo Dam", url: "http://www.wikidata.org/entity/Q115366520" }
  , { label: "22/05/1945 - Unknown - Attack on the NKVD Camp in Rembertów", url: "http://www.wikidata.org/entity/Q4818016" }
  , { label: "06/06/1945 - Poland - Wierzchowiny massacre", url: "http://www.wikidata.org/entity/Q9388694" }
  , { label: "20/07/1945 - Empire of Japan - Bombing of Okazaki in World War II", url: "http://www.wikidata.org/entity/Q11472974" }
  , { label: "24/07/1945 - Unknown - Battle of Sagami Bay", url: "http://www.wikidata.org/entity/Q717511" }
  , { label: "25/07/1945 - Philippines - Action of 24 July 1945", url: "http://www.wikidata.org/entity/Q16056966" }
  , { label: "28/07/1945 - Unknown - Q4488559", url: "http://www.wikidata.org/entity/Q4488559" }
  , { label: "09/08/1945 - Unknown - Soviet–Japanese War", url: "http://www.wikidata.org/entity/Q220602" }
  , { label: "10/08/1945 - Japan - Q119294378", url: "http://www.wikidata.org/entity/Q119294378" }
  , { label: "17/08/1945 - North Korea - Seishin Operation", url: "http://www.wikidata.org/entity/Q4448392" }
  , { label: "02/09/1945 - Empire of Japan - surrender of Japan", url: "http://www.wikidata.org/entity/Q6540361" }
  , { label: "03/09/1945 - Unknown - Operation Jurist", url: "http://www.wikidata.org/entity/Q28925560" }
  , { label: "12/09/1945 - Unknown - Operation Tiderace", url: "http://www.wikidata.org/entity/Q7097635" }
  , { label: "01/10/1945 - Australia - Operation Agas", url: "http://www.wikidata.org/entity/Q20981832" }
  , { label: "01/01/1946 - Unknown - Paris Peace Conference, 1946", url: "http://www.wikidata.org/entity/Q5782887" }
  ]
