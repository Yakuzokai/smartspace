<?php

namespace App\Console\Commands;

use App\Models\Furniture;
use App\Models\FurnitureModel;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;

class SyncFurnitureModels extends Command
{
    protected $signature = 'furniture:sync-models {--dry-run : Preview changes without writing to database}';
    protected $description = 'Scan storage/app/public/furniture/models for GLB files, link to Furniture catalog by SKU, and update database records';

    public function handle(): int
    {
        $isDryRun = (bool) $this->option('dry-run');
        $modelsDir = storage_path('app/public/furniture/models');

        $this->info("================================================================================");
        $this->info("  SMARTSPACE — 3D FURNITURE MODEL SYNCHRONIZATION");
        $this->info("  Scanning Directory: {$modelsDir}");
        if ($isDryRun) {
            $this->warn("  MODE: DRY-RUN (No database modifications will be made)");
        }
        $this->info("================================================================================");
        $this->newLine();

        if (!File::isDirectory($modelsDir)) {
            $this->error("Directory does not exist: {$modelsDir}");
            return Command::FAILURE;
        }

        $glbFiles = File::glob("{$modelsDir}/*.glb");
        $allFurniture = Furniture::all()->keyBy('sku');

        $syncedRows = [];
        $unmappedFiles = [];
        $syncedCount = 0;

        foreach ($glbFiles as $filePath) {
            $fileName = basename($filePath);
            $skuCandidate = strtoupper(pathinfo($fileName, PATHINFO_FILENAME));
            $fileSizeMb = round(filesize($filePath) / (1024 * 1024), 2);
            $publicPath = "/storage/furniture/models/{$fileName}";

            // Match SKU directly or prefix (e.g. COFF-001 or COFF-001_triposr -> COFF-001)
            $matchedFurniture = $allFurniture->get($skuCandidate);
            if (!$matchedFurniture) {
                // Try splitting by underscore or dash suffix
                $parts = explode('_', $skuCandidate);
                $matchedFurniture = $allFurniture->get($parts[0] ?? '');
            }

            if ($matchedFurniture) {
                if (!$isDryRun) {
                    // Update main furniture record
                    $matchedFurniture->glb_model_path = $publicPath;
                    $matchedFurniture->saveQuietly();

                    // Update or create dedicated furniture_models record
                    FurnitureModel::updateOrCreate(
                        [
                            'furniture_id' => $matchedFurniture->id,
                            'format' => 'glb',
                        ],
                        [
                            'model_path' => $publicPath,
                            'file_size_mb' => $fileSizeMb,
                            'is_optimized' => true,
                            'draco_compressed' => false,
                        ]
                    );
                }

                $dimStr = "{$matchedFurniture->width_cm}x{$matchedFurniture->depth_cm}x{$matchedFurniture->height_cm} cm";
                $syncedRows[] = [
                    $matchedFurniture->sku,
                    $matchedFurniture->name,
                    $dimStr,
                    "{$fileSizeMb} MB",
                    $fileName,
                    '<fg=green>Linked / Active</>',
                ];
                $syncedCount++;
            } else {
                $unmappedFiles[] = [
                    $fileName,
                    "{$fileSizeMb} MB",
                    '<fg=yellow>No matching SKU in catalog</>',
                ];
            }
        }

        if (!empty($syncedRows)) {
            $this->info("▶ SYNCHRONIZED 3D GLB MODELS ({$syncedCount})");
            $this->table(
                ['SKU', 'Name', 'Dimensions', 'File Size', 'GLB Filename', 'Status'],
                $syncedRows
            );
            $this->newLine();
        } else {
            $this->warn("No GLB files matched active catalog items.");
            $this->newLine();
        }

        if (!empty($unmappedFiles)) {
            $this->warn("▶ UNMAPPED GLB FILES (" . count($unmappedFiles) . ")");
            $this->table(['Filename', 'File Size', 'Reason'], $unmappedFiles);
            $this->newLine();
        }

        // Summary of catalog coverage
        $totalCatalog = $allFurniture->count();
        $itemsWithGlb = Furniture::whereNotNull('glb_model_path')->count();
        $itemsProcedural = $totalCatalog - $itemsWithGlb;

        $this->info("▶ CATALOG 3D COVERAGE SUMMARY");
        $this->line("  Total Catalog Furniture:    {$totalCatalog}");
        $this->line("  Loaded GLB 3D Meshes:       <fg=green>{$itemsWithGlb}</>");
        $this->line("  Procedural Representation:  <fg=cyan>{$itemsProcedural}</> (Certified fallback)");
        $this->newLine();

        if ($isDryRun) {
            $this->info("Dry run complete. Re-run without --dry-run to commit changes.");
        } else {
            $this->info("All models successfully synchronized! Three.js will load them immediately.");
        }

        return Command::SUCCESS;
    }
}
