package com.nutriscan.nutriscanbackend.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class LlmFoodService {

    @Value("${gemini.api.key:}")
    private String geminiApiKey;

    public String correctAndTranslateFood(String rawFoodName) {
        if (rawFoodName == null || rawFoodName.trim().isEmpty()) {
            return "";
        }

        if (geminiApiKey == null || geminiApiKey.trim().isEmpty()) {
            log.info("Gemini API key is not configured. Using local fallback for food name: {}", rawFoodName);
            return localFallbackTranslate(rawFoodName);
        }

        try {
            RestTemplate restTemplate = new RestTemplate();
            String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + geminiApiKey;

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            String prompt = String.format(
                    "You are a food name translation and normalization assistant. Your task is to translate and correct food names returned by an AI model to natural-sounding Turkish names.\n" +
                    "Instructions:\n" +
                    "1. The input may contain underscores, typos, or be in English.\n" +
                    "2. Correct any typos (e.g. 'brocoli' to 'Brokoli').\n" +
                    "3. Replace underscores or dashes with spaces if necessary (e.g. 'cup_cakes' to 'Kup kek').\n" +
                    "4. Translate the food name to Turkish.\n" +
                    "5. Respond with ONLY the final corrected Turkish name. Do not write any explanations, markdown, quotes or punctuation.\n" +
                    "Input: %s",
                    rawFoodName
            );

            Map<String, Object> textPart = new HashMap<>();
            textPart.put("text", prompt);

            Map<String, Object> partsMap = new HashMap<>();
            partsMap.put("parts", List.of(textPart));

            Map<String, Object> payload = new HashMap<>();
            payload.put("contents", List.of(partsMap));

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
            Map<String, Object> response = restTemplate.postForObject(url, entity, Map.class);

            if (response != null && response.containsKey("candidates")) {
                List<Map<String, Object>> candidates = (List<Map<String, Object>>) response.get("candidates");
                if (!candidates.isEmpty()) {
                    Map<String, Object> firstCandidate = candidates.get(0);
                    Map<String, Object> content = (Map<String, Object>) firstCandidate.get("content");
                    List<Map<String, Object>> parts = (List<Map<String, Object>>) content.get("parts");
                    if (!parts.isEmpty()) {
                        String text = (String) parts.get(0).get("text");
                        if (text != null && !text.trim().isEmpty()) {
                            String result = text.trim();
                            log.info("Successfully corrected food name via Gemini: '{}' -> '{}'", rawFoodName, result);
                            return result;
                        }
                    }
                }
            }
        } catch (Exception e) {
            log.error("Failed to correct food name via Gemini API: {}. Using fallback.", e.getMessage());
        }

        return localFallbackTranslate(rawFoodName);
    }

    private String localFallbackTranslate(String rawFoodName) {
        if (rawFoodName == null) return "";
        String cleaned = rawFoodName.replace("_", " ").replace("-", " ").trim().toLowerCase();

        Map<String, String> dict = new HashMap<>();
        dict.put("cup cakes", "Kup kek");
        dict.put("cup cake", "Kup kek");
        dict.put("cupcakes", "Kup kek");
        dict.put("cupcake", "Kup kek");
        dict.put("brocoli", "Brokoli");
        dict.put("broccoli", "Brokoli");
        dict.put("rice", "Pilav");
        dict.put("fried rice", "Kızarmış pilav");
        dict.put("french fries", "Patates kızartması");
        dict.put("pizza", "Pizza");
        dict.put("hamburger", "Hamburger");
        dict.put("sandwich", "Sandviç");
        dict.put("egg", "Yumurta");
        dict.put("fried egg", "Sahanda yumurta");
        dict.put("boiled egg", "Haşlanmış yumurta");
        dict.put("sushi", "Suşi");
        dict.put("curry", "Köri");
        dict.put("spaghetti", "Spagetti");
        dict.put("pasta", "Makarna");
        dict.put("chicken", "Tavuk");
        dict.put("fried chicken", "Kızarmış tavuk");
        dict.put("salad", "Salata");
        dict.put("soup", "Çorba");
        dict.put("beef", "Sığır eti");
        dict.put("fish", "Balık");
        dict.put("apple", "Elma");
        dict.put("banana", "Muz");
        dict.put("orange", "Portakal");
        dict.put("strawberry", "Çilek");
        dict.put("tomato", "Domates");
        dict.put("onion", "Soğan");
        dict.put("potato", "Patates");
        dict.put("cheese", "Peynir");
        dict.put("bread", "Ekmek");
        dict.put("milk", "Süt");
        dict.put("yogurt", "Yoğurt");
        dict.put("water", "Su");
        dict.put("coffee", "Kahve");
        dict.put("tea", "Çay");

        if (dict.containsKey(cleaned)) {
            return dict.get(cleaned);
        }

        // Capitalize first letter of each word
        String[] words = cleaned.split("\\s+");
        StringBuilder sb = new StringBuilder();
        for (String w : words) {
            if (!w.isEmpty()) {
                sb.append(Character.toUpperCase(w.charAt(0)))
                  .append(w.substring(1))
                  .append(" ");
            }
        }
        return sb.toString().trim();
    }

    public String checkAllergenWarning(String foodName, List<String> allergens) {
        if (foodName == null || foodName.isEmpty() || allergens == null || allergens.isEmpty()) {
            return null;
        }

        if (geminiApiKey == null || geminiApiKey.trim().isEmpty()) {
            log.info("Gemini API key is not configured. Skipping LLM allergen check.");
            return localAllergenCheck(foodName, allergens);
        }

        try {
            RestTemplate restTemplate = new RestTemplate();
            String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + geminiApiKey;

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            String prompt = String.format(
                    "You are an expert food safety and allergy assistant. Analyze if the food item '%s' contains or is likely to contain any of the following user allergens: %s.\n\n" +
                    "Instructions:\n" +
                    "1. Evaluate if the food typically contains or is made using the listed allergens.\n" +
                    "2. If it contains one or more allergens, generate a friendly and clear warning in Turkish. Example warning: 'Uyarı: Bu yiyecek alerjiniz olan süt ve yumurta içerebilir.'\n" +
                    "3. If it is safe and does not contain any of the allergens, respond with ONLY the word 'SAFE'.\n" +
                    "4. If there is a match, respond with ONLY the warning message in Turkish. Do not add any markdown, notes, explanations, or quotes. Just the plain text warning or 'SAFE'.",
                    foodName,
                    String.join(", ", allergens)
            );

            Map<String, Object> textPart = new HashMap<>();
            textPart.put("text", prompt);

            Map<String, Object> partsMap = new HashMap<>();
            partsMap.put("parts", List.of(textPart));

            Map<String, Object> payload = new HashMap<>();
            payload.put("contents", List.of(partsMap));

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
            Map<String, Object> response = restTemplate.postForObject(url, entity, Map.class);

            if (response != null && response.containsKey("candidates")) {
                List<Map<String, Object>> candidates = (List<Map<String, Object>>) response.get("candidates");
                if (!candidates.isEmpty()) {
                    Map<String, Object> firstCandidate = candidates.get(0);
                    Map<String, Object> content = (Map<String, Object>) firstCandidate.get("content");
                    List<Map<String, Object>> parts = (List<Map<String, Object>>) content.get("parts");
                    if (!parts.isEmpty()) {
                        String text = (String) parts.get(0).get("text");
                        if (text != null) {
                            String result = text.trim();
                            if ("SAFE".equalsIgnoreCase(result)) {
                                return null;
                            }
                            log.info("Allergen warning generated for food '{}': '{}'", foodName, result);
                            return result;
                        }
                    }
                }
            }
        } catch (Exception e) {
            log.error("Failed to check allergens via Gemini API: {}", e.getMessage());
        }

        return localAllergenCheck(foodName, allergens);
    }

    private String localAllergenCheck(String foodName, List<String> allergens) {
        if (foodName == null || allergens == null || allergens.isEmpty()) {
            return null;
        }
        String foodLower = foodName.toLowerCase();
        List<String> matchedAllergens = new java.util.ArrayList<>();

        for (String allergen : allergens) {
            String allergenLower = allergen.toLowerCase();
            if (allergenLower.contains("süt") || allergenLower.contains("milk") || allergenLower.contains("lactose") || allergenLower.contains("laktoz")) {
                if (foodLower.contains("pizza") || foodLower.contains("cheese") || foodLower.contains("peynir") || foodLower.contains("cup") || foodLower.contains("kek") || foodLower.contains("yoğurt") || foodLower.contains("yogurt") || foodLower.contains("süt") || foodLower.contains("milk") || foodLower.contains("dondurma") || foodLower.contains("ice cream")) {
                    matchedAllergens.add("süt/laktoz");
                }
            }
            if (allergenLower.contains("yumurta") || allergenLower.contains("egg")) {
                if (foodLower.contains("yumurta") || foodLower.contains("egg") || foodLower.contains("kek") || foodLower.contains("cake") || foodLower.contains("makarna") || foodLower.contains("pasta") || foodLower.contains("mayonez") || foodLower.contains("mayo")) {
                    matchedAllergens.add("yumurta");
                }
            }
            if (allergenLower.contains("gluten") || allergenLower.contains("buğday") || allergenLower.contains("wheat")) {
                if (foodLower.contains("ekmek") || foodLower.contains("bread") || foodLower.contains("makarna") || foodLower.contains("pasta") || foodLower.contains("kek") || foodLower.contains("cake") || foodLower.contains("pizza") || foodLower.contains("un") || foodLower.contains("flour")) {
                    matchedAllergens.add("gluten");
                }
            }
            if (allergenLower.contains("fıstık") || allergenLower.contains("peanut") || allergenLower.contains("nut")) {
                if (foodLower.contains("çikolata") || foodLower.contains("chocolate") || foodLower.contains("fıstık") || foodLower.contains("peanut") || foodLower.contains("çerez") || foodLower.contains("nut")) {
                    matchedAllergens.add("kuruyemiş/fıstık");
                }
            }
        }

        if (!matchedAllergens.isEmpty()) {
            return "Uyarı: Bu yiyecek alerjiniz olan " + String.join(", ", matchedAllergens) + " içerebilir.";
        }

        return null;
    }
}
