package com.invisible.facs.config;

import com.invisible.facs.model.Station;
import com.invisible.facs.model.Transaction;
import com.invisible.facs.model.TransactionStatus;
import com.invisible.facs.model.Vehicle;
import com.invisible.facs.repository.StationRepository;
import com.invisible.facs.repository.TransactionRepository;
import com.invisible.facs.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@Component
@RequiredArgsConstructor
public class TransactionBootstrap implements CommandLineRunner {

    private final TransactionRepository transactionRepository;
    private final StationRepository stationRepository;
    private final VehicleRepository vehicleRepository;

    @Override
    public void run(String... args) {
        if (transactionRepository.count() > 0) return;
        List<Station> stations = stationRepository.findAll();
        List<Vehicle> vehicles = vehicleRepository.findAll();
        if (stations.isEmpty() || vehicles.isEmpty()) return;

        Instant now = Instant.now();
        Object[][] seedData = {
                {"FACS-98421", 0, 0, "125.50", TransactionStatus.SUCCESS, now.minus(2, ChronoUnit.HOURS)},
                {"FACS-98422", 0, 0, "80.00",  TransactionStatus.PENDING, now.minus(3, ChronoUnit.HOURS)},
                {"FACS-98423", 0, 0, "0.00",   TransactionStatus.CANCELLED, now.minus(1, ChronoUnit.DAYS)},
                {"FACS-98424", 0, 0, "50.25",  TransactionStatus.SUCCESS, now.minus(1, ChronoUnit.DAYS).minus(2, ChronoUnit.HOURS)},
        };

        List<Transaction> seeds = new ArrayList<>();
        for (Object[] row : seedData) {
            Vehicle vehicle = vehicles.get(((int) row[1]) % vehicles.size());
            Station station = stations.get(((int) row[2]) % stations.size());

            seeds.add(Transaction.builder()
                    .code((String) row[0])
                    .vehicle(vehicle)
                    .station(station)
                    .fuelLiters(new BigDecimal((String) row[3]))
                    .status((TransactionStatus) row[4])
                    .createdAt((Instant) row[5])
                    .build());
        }
        transactionRepository.saveAll(seeds);
    }
}
