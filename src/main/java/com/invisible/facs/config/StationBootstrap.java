package com.invisible.facs.config;

import com.invisible.facs.model.Station;
import com.invisible.facs.repository.StationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class StationBootstrap implements CommandLineRunner {

    private final StationRepository stationRepository;

    @Override
    public void run(String... args) {
        if (stationRepository.count() > 0) {
            return;
        }
        List<Station> seeds = List.of(
                Station.builder().code("T-0982").name("তেজগাঁও মেইন ডিপো").location("ঢাকা মেট্রো, বাংলাদেশ").build(),
                Station.builder().code("T-1143").name("পতেঙ্গা সরবরাহ কেন্দ্র").location("চট্টগ্রাম বন্দর এলাকা").build(),
                Station.builder().code("T-0421").name("যমুনা ওয়েস্টার্ন ইউনিট").location("সাভার, ঢাকা").build(),
                Station.builder().code("T-2219").name("বগুড়া ডিস্ট্রিবিউশন পয়েন্ট").location("বগুড়া সদর").build()
        );
        stationRepository.saveAll(seeds);
    }
}
