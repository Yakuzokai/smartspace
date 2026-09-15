-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 15, 2026 at 03:06 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `smartspace`
--

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `parent_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `parent_id`, `name`, `slug`, `description`, `icon`, `is_active`, `created_at`, `updated_at`) VALUES
(1, NULL, 'Living Room', 'living-room', 'Furniture and accessories for communal lounging and living spaces.', 'couch', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(2, 1, 'Sofas & Lounging', 'sofas-lounging', '2-seaters, 3-seaters, modular sectionals, and daybeds.', 'sofa', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(3, 1, 'Coffee & Side Tables', 'coffee-side-tables', 'Low central tables, nesting sets, and side tables.', 'table', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(4, 1, 'Media & TV Units', 'media-tv-units', 'Entertainment centers, credenzas, and media benches.', 'tv', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(5, 1, 'Accent & Storage Units', 'accent-storage', 'Bookcases, room dividers, armchairs, and entryway units.', 'archive', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(6, NULL, 'Bedroom', 'bedroom', 'Bedframes, storage beds, and nightstands for sleeping quarters.', 'bed', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(7, 6, 'Beds & Mattresses', 'beds-mattresses', 'Single, queen, king, and platform storage beds.', 'bed-double', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(8, 6, 'Nightstands & Bedside Storage', 'nightstands', 'Compact bedside drawers, floating shelves, and nightstands.', 'clock', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(9, NULL, 'Home Office', 'home-office', 'Desks, computer workstations, and ergonomic workspace furniture.', 'laptop', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(10, 9, 'Desks & Workstations', 'desks-workstations', 'Compact writing desks, executive desks, and sit-stand desks.', 'briefcase', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(11, NULL, 'Dining', 'dining', 'Dining tables and chairs for meals and entertaining.', 'utensils', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(12, 11, 'Dining Tables', 'dining-tables', 'Circular, rectangular, and extendable dining tables.', 'table-restaurant', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(13, 11, 'Dining Chairs', 'dining-chairs', 'Ergonomic, upholstered, and minimalist dining seating.', 'chair', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01');

-- --------------------------------------------------------

--
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `furniture_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `favorites`
--

INSERT INTO `favorites` (`id`, `user_id`, `furniture_id`, `created_at`) VALUES
(1, 2, 1, '2026-09-12 12:57:01'),
(2, 2, 12, '2026-09-12 12:57:01'),
(3, 2, 25, '2026-09-12 12:57:01');

-- --------------------------------------------------------

--
-- Table structure for table `furniture`
--

CREATE TABLE `furniture` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `sku` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `width_cm` decimal(8,2) NOT NULL,
  `height_cm` decimal(8,2) NOT NULL,
  `depth_cm` decimal(8,2) NOT NULL,
  `clearance_front_cm` decimal(8,2) NOT NULL DEFAULT 75.00,
  `clearance_side_cm` decimal(8,2) NOT NULL DEFAULT 60.00,
  `style` varchar(255) NOT NULL,
  `material` varchar(255) DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `color_hex` varchar(7) DEFAULT NULL,
  `glb_model_path` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `furniture`
--

INSERT INTO `furniture` (`id`, `category_id`, `sku`, `name`, `description`, `price`, `width_cm`, `height_cm`, `depth_cm`, `clearance_front_cm`, `clearance_side_cm`, `style`, `material`, `color`, `color_hex`, `glb_model_path`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 2, 'SOFA-001', 'Nordik 3-Seater Minimalist Sofa', 'Tailored three-seater sofa featuring clean architectural lines, high-density resilience foam, and tapered solid ash legs.', 849.00, 210.00, 82.00, 88.00, 80.00, 50.00, 'scandinavian', 'Linen Fabric & Ash Wood', 'Warm Grey', '#A8A6A1', '/storage/furniture/models/SOFA-001.glb', 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(2, 2, 'SOFA-002', 'Loft 2-Seater Compact Studio Sofa', 'Compact deep-seat loveseat ideal for urban apartments and smaller living spaces, upholstered in tactile boucle.', 580.00, 152.00, 78.00, 82.00, 70.00, 40.00, 'minimalist', 'Boucle Fabric', 'Cream White', '#F3EFEA', '/storage/furniture/models/SOFA-002.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(3, 2, 'SOFA-003', 'Manhattan L-Shaped Sectional Sofa', 'Generous family-sized corner sectional with right-hand chaise, wrapped in hand-finished top-grain saddle leather.', 1850.00, 280.00, 84.00, 165.00, 90.00, 60.00, 'modern', 'Top-Grain Leather', 'Cognac Brown', '#8B4513', '/storage/furniture/models/SOFA-003.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(4, 2, 'SOFA-004', 'Ironworks Industrial Tufted Loveseat', 'Rugged industrial loveseat pairing distressed caramel leather cushions with a welded blackened steel frame.', 920.00, 165.00, 80.00, 86.00, 75.00, 50.00, 'industrial', 'Aged Leather & Black Steel', 'Charcoal Brown', '#3E3430', '/storage/furniture/models/SOFA-004.glb', 1, '2026-09-12 04:57:01', '2026-09-15 02:15:47'),
(5, 2, 'SOFA-005', 'Kyoto Low Platform Daybed', 'Zen-inspired minimalist daybed with an oiled American walnut frame and a supportive natural cotton futon cushion.', 740.00, 195.00, 65.00, 80.00, 70.00, 40.00, 'minimalist', 'Natural Walnut & Cotton', 'Sand Beige', '#D2B48C', '/storage/furniture/models/SOFA-005.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(6, 2, 'SOFA-006', 'Chesterfield Heritage 3-Seater', 'Classic rolled-arm sofa featuring deep button-tufted upholstery in rich jewel-tone velvet.', 1450.00, 225.00, 76.00, 92.00, 85.00, 60.00, 'classic', 'Deep Buttoned Velvet', 'Forest Green', '#1E3F20', '/storage/furniture/models/SOFA-006.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:25:35'),
(7, 3, 'COFF-001', 'Aura Oval Glass & Oak Coffee Table', 'Organic oval silhouette featuring a floating tempered glass surface resting on a sculptural solid white oak base.', 290.00, 110.00, 42.00, 60.00, 50.00, 50.00, 'scandinavian', 'Tempered Glass & Solid Oak', 'Natural Oak', '#C8B195', '/storage/furniture/models/COFF-001.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(8, 3, 'COFF-002', 'Mono Block Minimalist Low Table', 'Architectural monolith table with a seamless micro-cement finish, grounding the living space in pure geometry.', 340.00, 90.00, 36.00, 90.00, 45.00, 45.00, 'minimalist', 'Micro-cement Finish', 'Matte Slate', '#4A5056', '/storage/furniture/models/COFF-002.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(9, 3, 'COFF-003', 'Factory Round Nesting Tables (Pair)', 'Two nesting circular accent tables crafted from reclaimed teak planks with hand-welded iron band frames.', 260.00, 80.00, 45.00, 80.00, 40.00, 40.00, 'industrial', 'Reclaimed Teak & Matte Black Iron', 'Distressed Teak', '#634735', '/storage/furniture/models/COFF-003.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:34'),
(10, 3, 'COFF-004', 'Verona Marble Rectangular Coffee Table', 'Honed Italian Carrara marble slab mounted on an understated satin brass architectural underframe.', 620.00, 120.00, 40.00, 65.00, 50.00, 50.00, 'modern', 'Carrara Marble & Brass', 'Carrara White', '#F0EEE9', '/storage/furniture/models/COFF-004.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:35'),
(11, 4, 'TV-001', 'Horizon 180 Floating Wall Console', 'Wall-mounted floating media unit with integrated cable raceway, push-to-open acoustic fabric drop-down fronts.', 420.00, 180.00, 32.00, 38.00, 80.00, 30.00, 'minimalist', 'Matte Lacquer & Oak Veneer', 'Arctic White / Oak', '#F8F8F8', '/storage/furniture/models/TV-001.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(12, 4, 'TV-002', 'Oslo Low Media Bench 200cm', 'Substantial Nordic entertainment credenza featuring tambour slatted sliding doors and wire-pass dividers.', 680.00, 200.00, 48.00, 45.00, 90.00, 40.00, 'scandinavian', 'Solid White Oak & Slatted Doors', 'Nordic Oak', '#DEC5A5', '/storage/furniture/models/TV-002.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(13, 4, 'TV-003', 'Brooklyn Steel-Mesh Credenza', 'Heavy-gauge steel frame with perforated mesh doors allowing remote control IR pass-through, topped with aged elm.', 540.00, 160.00, 60.00, 42.00, 75.00, 30.00, 'industrial', 'Perforated Steel & Elm Wood', 'Industrial Black', '#262626', '/storage/furniture/models/TV-003.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:35'),
(14, 4, 'TV-004', 'Palais Walnut Sideboard Console', 'Substantial mid-century influenced sideboard with bookmatched walnut veneer and brushed antique brass pulls.', 890.00, 175.00, 75.00, 46.00, 80.00, 35.00, 'classic', 'American Walnut & Brass Knobs', 'Dark Walnut', '#442B15', '/storage/furniture/models/TV-004.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(15, 7, 'BED-001', 'Fjord Single Platform Bed (90x200)', 'Clean-lined solid birch bed frame designed for standard single 90x200 cm mattresses with integrated posture slats.', 380.00, 98.00, 90.00, 208.00, 60.00, 60.00, 'scandinavian', 'Solid Birch', 'Light Birch', '#E6DAC8', '/storage/furniture/models/BED-001.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(16, 7, 'BED-002', 'Astrid Queen Upholstered Bed (160x200)', 'Curved shelter headboard upholstered in durable heathered woven fabric with padded perimeter rails.', 790.00, 172.00, 110.00, 215.00, 75.00, 60.00, 'modern', 'Textured Woven Fabric & Foam', 'Muted Sand', '#D7CEC7', '/storage/furniture/models/BED-002.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(17, 7, 'BED-003', 'Skan King Hydraulic Storage Bed (180x200)', 'Effortless gas-lift hydraulic mechanism revealing cavernous under-bed storage without sacrificing clean Nordic aesthetics.', 1150.00, 194.00, 105.00, 216.00, 80.00, 65.00, 'scandinavian', 'Oak Veneer with Gas-Lift Storage', 'Natural Oak', '#C2A382', '/storage/furniture/models/BED-003.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:34'),
(18, 7, 'BED-004', 'Zen Low Tatami Platform King (180x200)', 'Ultra-low Japanese minimalist platform bed with an extended perimeter ledge crafted from sustainably harvested cedar.', 690.00, 210.00, 30.00, 220.00, 60.00, 50.00, 'minimalist', 'Solid Cedar & Ash', 'Raw Wood', '#CEB89E', '/storage/furniture/models/BED-004.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:34'),
(19, 7, 'BED-005', 'Grand Master Tufted King Bed (180x200)', 'High diamond-tufted linen headboard with handcrafted fluted posts for an elegant master bedroom aesthetic.', 1320.00, 196.00, 140.00, 222.00, 85.00, 70.00, 'classic', 'Padded Linen & Carved Wood', 'Oatmeal', '#E3DAC9', '/storage/furniture/models/BED-005.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:31:28'),
(20, 8, 'NST-001', 'Aero Floating Bedside Shelf', 'Wall-hung curved nightstand with concealed soft-close drawer, keeping floor space completely open.', 95.00, 42.00, 18.00, 32.00, 50.00, 20.00, 'minimalist', 'Bent Ash Plywood', 'Natural Ash', '#DFD2C0', '/storage/furniture/models/NST-001.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(21, 8, 'NST-002', 'Linnea 2-Drawer Oak Nightstand', 'Classic Scandinavian bedside chest with dovetailed joinery and recessed brass finger pulls.', 165.00, 48.00, 54.00, 40.00, 55.00, 25.00, 'scandinavian', 'Solid Oak & Brass Pulls', 'Honey Oak', '#C99E6B', '/storage/furniture/models/NST-002.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:35'),
(22, 8, 'NST-003', 'Foundry Open Wire Bedside Cube', 'Minimalist open-cage bedside locker featuring blackened iron mesh and a removable solid mango wood top.', 120.00, 40.00, 50.00, 38.00, 45.00, 20.00, 'industrial', 'Powder-coated Steel & Mango Wood', 'Matte Black', '#222222', '/storage/furniture/models/NST-003.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:35'),
(23, 8, 'NST-004', 'Grace Fluted Cylinder Pedestal', 'Round architectural nightstand with textured fluted casing and an inset engineered white stone top.', 210.00, 38.00, 52.00, 38.00, 45.00, 20.00, 'modern', 'Fluted Ceramic & Marble Top', 'Ivory White', '#F5F5F0', '/storage/furniture/models/NST-004.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:35'),
(24, 10, 'DSK-001', 'Solo Compact Study Desk 100x50', 'Slender workspace desk specifically proportioned for bedrooms and studio apartments with an integrated monitor shelf.', 185.00, 100.00, 75.00, 50.00, 80.00, 30.00, 'minimalist', 'Laminate & White Steel Frame', 'White / Birch', '#EBEAE6', '/storage/furniture/models/DSK-001.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(25, 10, 'DSK-002', 'ErgoPro Motorized Sit-Stand Desk 140x70', 'Dual-motor electric height-adjustable desk with memory presets, solid walnut desktop, and anti-collision sensor.', 580.00, 140.00, 72.00, 70.00, 90.00, 40.00, 'modern', 'Solid Walnut Top & Dual Motor Base', 'Warm Walnut', '#5C4033', '/storage/furniture/models/DSK-002.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(26, 10, 'DSK-003', 'Architect Drafting Studio Desk', 'Industrial drafting table with adjustable incline top, cast-iron crank wheels, and rustic pine timbers.', 440.00, 150.00, 76.00, 75.00, 85.00, 40.00, 'industrial', 'Cast Iron Trestles & Rustic Pine', 'Raw Pine / Cast Iron', '#876543', '/storage/furniture/models/DSK-003.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:35'),
(27, 10, 'DSK-004', 'Executive L-Shaped Corner Workstation', 'Comprehensive executive desk providing generous desktop area and integrated lockable filing drawers.', 790.00, 180.00, 75.00, 140.00, 95.00, 50.00, 'modern', 'Smoked Oak & Charcoal Metal', 'Smoked Oak', '#3B332C', '/storage/furniture/models/DSK-004.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:35'),
(28, 12, 'DTB-001', 'Circa 4-Seater Round Dining Table', 'Warm round solid ash table with conical pedestal base, maximizing knee clearance and intimacy in compact dining nooks.', 520.00, 110.00, 75.00, 110.00, 80.00, 80.00, 'scandinavian', 'Solid Ash with Pedestal Base', 'Blonde Ash', '#E2D3B8', '/storage/furniture/models/DTB-001.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(29, 12, 'DTB-002', 'Kanso 6-Seater Rectangular Dining Table', 'Pure minimalist dining table crafted from wide planks of solid European white oak with soft radius edges.', 740.00, 160.00, 76.00, 90.00, 85.00, 60.00, 'minimalist', 'Solid White Oak', 'Natural Oak', '#CCB290', '/storage/furniture/models/DTB-002.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(30, 12, 'DTB-003', 'Bastion 8-Seater Extendable Dining Table', 'Substantial live-edge walnut dining table with a butterfly internal extension mechanism expanding up to 260 cm.', 1180.00, 200.00, 76.00, 95.00, 90.00, 70.00, 'industrial', 'Live-Edge Walnut & U-Steel Legs', 'Deep Walnut', '#4A3525', '/storage/furniture/models/DTB-003.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(31, 13, 'DCH-001', 'Fawn Scandinavian Spindle Dining Chair', 'Timeless Windsor-inspired dining chair with turned beech spindles and a saddled ergonomic wooden seat.', 95.00, 46.00, 82.00, 49.00, 50.00, 20.00, 'scandinavian', 'Bentwood Beech', 'Natural Beech', '#D8C6A5', '/storage/furniture/models/DCH-001.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(32, 13, 'DCH-002', 'Port Upholstered Curved Back Armchair', 'Plush wrap-around curved back dining chair providing generous lumbar support during long dinner parties.', 155.00, 56.00, 78.00, 54.00, 55.00, 25.00, 'modern', 'Tweed Fabric & Matte Black Legs', 'Charcoal Grey', '#404040', '/storage/furniture/models/DCH-002.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(33, 13, 'DCH-003', 'Cantilever Chrome Leatherette Chair', 'Bauhaus-influenced S-curve tubular steel cantilever chair providing comfortable natural flex.', 130.00, 48.00, 84.00, 52.00, 50.00, 20.00, 'modern', 'Tubular Steel & Saddle Faux Leather', 'Caramel Brown', '#A0522D', '/storage/furniture/models/DCH-003.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(34, 13, 'DCH-004', 'Bento Minimalist Molded Shell Chair', 'Ultra-lightweight stackable molded polypropylene chair with matte texture and solid beech dowel legs.', 75.00, 48.00, 79.00, 47.00, 45.00, 20.00, 'minimalist', 'Recycled Polypropylene & Wood', 'Chalk White', '#F0EDE6', '/storage/furniture/models/DCH-004.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(35, 13, 'DCH-005', 'Bistro Wire Metal Dining Chair', 'Geometric wire grid chair with an electroplated gunmetal finish and a magnetic vegan leather seat cushion.', 88.00, 44.00, 80.00, 46.00, 45.00, 20.00, 'industrial', 'Welded Steel Rod with Leather Pad', 'Gunmetal Grey', '#33373B', '/storage/furniture/models/DCH-005.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(36, 13, 'DCH-006', 'Heritage Oak Dining Bench 140cm', 'Sturdy solid oak bench that slides completely under 160+ cm dining tables when not in active use.', 210.00, 140.00, 46.00, 36.00, 40.00, 20.00, 'scandinavian', 'Solid Oak with Rounded Edges', 'Natural Oak', '#CDB18B', '/storage/furniture/models/DCH-006.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:35'),
(37, 5, 'STG-001', 'Gridline Tall Open Modular Bookcase', 'Architectural steel frame bookcase featuring 5 staggered shelves of natural ash, perfect for room zoning.', 340.00, 90.00, 190.00, 34.00, 70.00, 25.00, 'minimalist', 'Powder-coated Steel & Ash Shelves', 'Matte Black & Ash', '#2A2927', '/storage/furniture/models/STG-001.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(38, 5, 'STG-002', 'Lattice Timber Room Divider / Screen', 'Freestanding vertical timber slat screen with an integrated planter box for creating privacy and zones in open plans.', 390.00, 120.00, 175.00, 30.00, 60.00, 30.00, 'scandinavian', 'Vertical Oak Slats & Planter Box', 'Nordic Oak', '#D5BE9E', '/storage/furniture/models/STG-002.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:35'),
(39, 5, 'STG-003', 'Hygge Cocoon Reading Armchair', 'Comfortable reading accent chair upholstered in plush shearling fleece with a 360-degree silent swivel oak base.', 540.00, 84.00, 92.00, 82.00, 75.00, 40.00, 'scandinavian', 'Shearling Fleece & Oak Swivel Base', 'Warm Oatmeal', '#EAE6DF', '/storage/furniture/models/STG-003.glb', 1, '2026-09-12 04:57:01', '2026-09-14 21:34:30'),
(40, 5, 'STG-004', 'Foyer Entryway Bench & Coat Rack', 'Multifunctional entry hall unit with a lower slatted shoe bench, cushioned seat, and 6 cast-iron coat hooks.', 260.00, 100.00, 180.00, 40.00, 70.00, 20.00, 'industrial', 'Reclaimed Pine & Black Iron Pipes', 'Dark Oak / Iron', '#3A2E28', '/storage/furniture/models/STG-004.glb', 1, '2026-09-12 04:57:01', '2026-09-15 03:39:35');

-- --------------------------------------------------------

--
-- Table structure for table `furniture_images`
--

CREATE TABLE `furniture_images` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `furniture_id` bigint(20) UNSIGNED NOT NULL,
  `image_path` varchar(255) NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `furniture_images`
--

INSERT INTO `furniture_images` (`id`, `furniture_id`, `image_path`, `is_primary`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 1, '/storage/furniture/images/SOFA-001-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(2, 2, '/storage/furniture/images/SOFA-002-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(3, 3, '/storage/furniture/images/SOFA-003-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(4, 4, '/storage/furniture/images/SOFA-004-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(5, 5, '/storage/furniture/images/SOFA-005-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(6, 6, '/storage/furniture/images/SOFA-006-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(7, 7, '/storage/furniture/images/COFF-001-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(8, 8, '/storage/furniture/images/COFF-002-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(9, 9, '/storage/furniture/images/COFF-003-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(10, 10, '/storage/furniture/images/COFF-004-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(11, 11, '/storage/furniture/images/TV-001-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(12, 12, '/storage/furniture/images/TV-002-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(13, 13, '/storage/furniture/images/TV-003-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(14, 14, '/storage/furniture/images/TV-004-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(15, 15, '/storage/furniture/images/BED-001-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(16, 16, '/storage/furniture/images/BED-002-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(17, 17, '/storage/furniture/images/BED-003-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(18, 18, '/storage/furniture/images/BED-004-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(19, 19, '/storage/furniture/images/BED-005-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(20, 20, '/storage/furniture/images/NST-001-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(21, 21, '/storage/furniture/images/NST-002-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(22, 22, '/storage/furniture/images/NST-003-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(23, 23, '/storage/furniture/images/NST-004-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(24, 24, '/storage/furniture/images/DSK-001-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(25, 25, '/storage/furniture/images/DSK-002-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(26, 26, '/storage/furniture/images/DSK-003-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(27, 27, '/storage/furniture/images/DSK-004-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(28, 28, '/storage/furniture/images/DTB-001-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(29, 29, '/storage/furniture/images/DTB-002-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(30, 30, '/storage/furniture/images/DTB-003-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(31, 31, '/storage/furniture/images/DCH-001-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(32, 32, '/storage/furniture/images/DCH-002-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(33, 33, '/storage/furniture/images/DCH-003-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(34, 34, '/storage/furniture/images/DCH-004-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(35, 35, '/storage/furniture/images/DCH-005-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(36, 36, '/storage/furniture/images/DCH-006-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(37, 37, '/storage/furniture/images/STG-001-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(38, 38, '/storage/furniture/images/STG-002-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(39, 39, '/storage/furniture/images/STG-003-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(40, 40, '/storage/furniture/images/STG-004-primary.webp', 1, 1, '2026-09-12 04:57:01', '2026-09-12 04:57:01');

-- --------------------------------------------------------

--
-- Table structure for table `furniture_models`
--

CREATE TABLE `furniture_models` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `furniture_id` bigint(20) UNSIGNED NOT NULL,
  `model_path` varchar(255) NOT NULL,
  `format` varchar(255) NOT NULL DEFAULT 'glb',
  `file_size_mb` decimal(8,2) NOT NULL DEFAULT 0.00,
  `is_optimized` tinyint(1) NOT NULL DEFAULT 1,
  `draco_compressed` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `furniture_models`
--

INSERT INTO `furniture_models` (`id`, `furniture_id`, `model_path`, `format`, `file_size_mb`, `is_optimized`, `draco_compressed`, `created_at`, `updated_at`) VALUES
(1, 1, '/storage/furniture/models/SOFA-001.glb', 'glb', 4.96, 1, 0, '2026-09-12 04:57:01', '2026-09-12 19:14:50'),
(41, 15, '/storage/furniture/models/BED-001.glb', 'glb', 1.18, 1, 0, '2026-09-14 21:34:30', '2026-09-14 21:34:30'),
(42, 16, '/storage/furniture/models/BED-002.glb', 'glb', 23.21, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:15:47'),
(43, 7, '/storage/furniture/models/COFF-001.glb', 'glb', 41.87, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:58:52'),
(44, 8, '/storage/furniture/models/COFF-002.glb', 'glb', 83.32, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:15:47'),
(45, 31, '/storage/furniture/models/DCH-001.glb', 'glb', 81.01, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:15:47'),
(46, 32, '/storage/furniture/models/DCH-002.glb', 'glb', 82.45, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:15:47'),
(47, 33, '/storage/furniture/models/DCH-003.glb', 'glb', 18.62, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:15:47'),
(48, 34, '/storage/furniture/models/DCH-004.glb', 'glb', 1.69, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:15:47'),
(49, 35, '/storage/furniture/models/DCH-005.glb', 'glb', 0.84, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:15:47'),
(50, 24, '/storage/furniture/models/DSK-001.glb', 'glb', 16.64, 1, 0, '2026-09-14 21:34:30', '2026-09-14 21:39:07'),
(51, 25, '/storage/furniture/models/DSK-002.glb', 'glb', 16.64, 1, 0, '2026-09-14 21:34:30', '2026-09-14 21:34:30'),
(52, 28, '/storage/furniture/models/DTB-001.glb', 'glb', 13.26, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:58:52'),
(53, 29, '/storage/furniture/models/DTB-002.glb', 'glb', 0.26, 1, 0, '2026-09-14 21:34:30', '2026-09-14 21:34:30'),
(54, 30, '/storage/furniture/models/DTB-003.glb', 'glb', 4.27, 1, 0, '2026-09-14 21:34:30', '2026-09-14 21:34:30'),
(55, 20, '/storage/furniture/models/NST-001.glb', 'glb', 4.67, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:15:47'),
(56, 2, '/storage/furniture/models/SOFA-002.glb', 'glb', 1.53, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:15:47'),
(57, 3, '/storage/furniture/models/SOFA-003.glb', 'glb', 10.15, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:15:47'),
(58, 5, '/storage/furniture/models/SOFA-005.glb', 'glb', 4.42, 1, 0, '2026-09-14 21:34:30', '2026-09-14 21:34:30'),
(59, 37, '/storage/furniture/models/STG-001.glb', 'glb', 0.01, 1, 0, '2026-09-14 21:34:30', '2026-09-15 03:39:35'),
(60, 39, '/storage/furniture/models/STG-003.glb', 'glb', 28.75, 1, 0, '2026-09-14 21:34:30', '2026-09-15 02:15:47'),
(61, 11, '/storage/furniture/models/TV-001.glb', 'glb', 0.01, 1, 0, '2026-09-14 21:34:30', '2026-09-15 03:39:35'),
(62, 12, '/storage/furniture/models/TV-002.glb', 'glb', 1.34, 1, 0, '2026-09-14 21:34:30', '2026-09-14 21:34:30'),
(63, 14, '/storage/furniture/models/TV-004.glb', 'glb', 1.34, 1, 0, '2026-09-14 21:34:30', '2026-09-14 21:34:30'),
(64, 4, '/storage/furniture/models/SOFA-004.glb', 'glb', 1.11, 1, 0, '2026-09-15 02:15:47', '2026-09-15 02:15:47'),
(65, 6, '/storage/furniture/models/SOFA-006.glb', 'glb', 37.91, 1, 0, '2026-09-15 03:25:35', '2026-09-15 03:25:35'),
(66, 19, '/storage/furniture/models/BED-005.glb', 'glb', 0.01, 1, 0, '2026-09-15 03:31:28', '2026-09-15 03:31:28'),
(67, 17, '/storage/furniture/models/BED-003.glb', 'glb', 0.01, 1, 0, '2026-09-15 03:39:34', '2026-09-15 03:39:34'),
(68, 18, '/storage/furniture/models/BED-004.glb', 'glb', 0.01, 1, 0, '2026-09-15 03:39:34', '2026-09-15 03:39:34'),
(69, 9, '/storage/furniture/models/COFF-003.glb', 'glb', 0.05, 1, 0, '2026-09-15 03:39:35', '2026-09-15 03:39:35'),
(70, 10, '/storage/furniture/models/COFF-004.glb', 'glb', 0.03, 1, 0, '2026-09-15 03:39:35', '2026-09-15 03:39:35'),
(71, 36, '/storage/furniture/models/DCH-006.glb', 'glb', 0.03, 1, 0, '2026-09-15 03:39:35', '2026-09-15 03:39:35'),
(72, 26, '/storage/furniture/models/DSK-003.glb', 'glb', 0.00, 1, 0, '2026-09-15 03:39:35', '2026-09-15 03:39:35'),
(73, 27, '/storage/furniture/models/DSK-004.glb', 'glb', 0.01, 1, 0, '2026-09-15 03:39:35', '2026-09-15 03:39:35'),
(74, 21, '/storage/furniture/models/NST-002.glb', 'glb', 0.05, 1, 0, '2026-09-15 03:39:35', '2026-09-15 03:39:35'),
(75, 22, '/storage/furniture/models/NST-003.glb', 'glb', 0.03, 1, 0, '2026-09-15 03:39:35', '2026-09-15 03:39:35'),
(76, 23, '/storage/furniture/models/NST-004.glb', 'glb', 0.02, 1, 0, '2026-09-15 03:39:35', '2026-09-15 03:39:35'),
(77, 38, '/storage/furniture/models/STG-002.glb', 'glb', 0.00, 1, 0, '2026-09-15 03:39:35', '2026-09-15 03:39:35'),
(78, 40, '/storage/furniture/models/STG-004.glb', 'glb', 0.05, 1, 0, '2026-09-15 03:39:35', '2026-09-15 03:39:35'),
(79, 13, '/storage/furniture/models/TV-003.glb', 'glb', 0.03, 1, 0, '2026-09-15 03:39:35', '2026-09-15 03:39:35');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2026_09_12_000001_create_roles_table', 1),
(2, '2026_09_12_000002_create_users_table', 1),
(3, '2026_09_12_000003_create_personal_access_tokens_table', 1),
(4, '2026_09_12_000004_create_categories_table', 1),
(5, '2026_09_12_000005_create_furniture_table', 1),
(6, '2026_09_12_000006_create_furniture_images_table', 1),
(7, '2026_09_12_000007_create_furniture_models_table', 1),
(8, '2026_09_12_000008_create_room_projects_table', 1),
(9, '2026_09_12_000009_create_room_project_furniture_table', 1),
(10, '2026_09_12_000010_create_room_analyses_table', 1),
(11, '2026_09_12_000011_create_favorites_table', 1),
(12, '2026_09_15_000001_create_orders_tables', 2);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_number` varchar(64) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'confirmed',
  `payment_method` varchar(32) NOT NULL DEFAULT 'cod',
  `payment_status` varchar(32) NOT NULL DEFAULT 'pending',
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `shipping_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `shipping_first_name` varchar(100) NOT NULL,
  `shipping_last_name` varchar(100) NOT NULL,
  `shipping_email` varchar(150) NOT NULL,
  `shipping_phone` varchar(50) NOT NULL,
  `shipping_address_line1` varchar(255) NOT NULL,
  `shipping_address_line2` varchar(255) DEFAULT NULL,
  `shipping_city` varchar(100) NOT NULL,
  `shipping_province` varchar(100) NOT NULL DEFAULT 'Metro Manila',
  `shipping_postal_code` varchar(20) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `order_number`, `user_id`, `status`, `payment_method`, `payment_status`, `subtotal`, `shipping_fee`, `discount_amount`, `total_amount`, `shipping_first_name`, `shipping_last_name`, `shipping_email`, `shipping_phone`, `shipping_address_line1`, `shipping_address_line2`, `shipping_city`, `shipping_province`, `shipping_postal_code`, `notes`, `created_at`, `updated_at`) VALUES
(1, 'ORD-20260915-MPHO', NULL, 'confirmed', 'cod', 'pending', 1698.00, 0.00, 0.00, 1698.00, 'Maria', 'Santos', 'maria.santos@example.com', '+63 917 123 4567', 'Unit 14B Minimalist Tower, Ayala Ave', 'Bel-Air', 'Makati', 'Metro Manila', '1209', 'Please call upon arrival at the lobby', '2026-09-14 20:36:55', '2026-09-14 20:36:55'),
(2, 'ORD-20260915-QA0E', NULL, 'confirmed', 'cod', 'pending', 1698.00, 0.00, 0.00, 1698.00, 'Maria', 'Santos', 'maria.santos@example.com', '+63 917 123 4567', 'Unit 14B Minimalist Tower, Ayala Ave', 'Bel-Air', 'Makati', 'Metro Manila', '1209', 'Please call upon arrival at the lobby', '2026-09-14 20:37:06', '2026-09-14 20:37:06'),
(3, 'ORD-20260915-RWTA', NULL, 'confirmed', 'cod', 'pending', 1698.00, 0.00, 0.00, 1698.00, 'Maria', 'Santos', 'maria.santos@example.com', '+63 917 123 4567', 'Unit 14B Minimalist Tower, Ayala Ave', 'Bel-Air', 'Makati', 'Metro Manila', '1209', 'Please call upon arrival at the lobby', '2026-09-14 20:37:16', '2026-09-14 20:37:16'),
(4, 'ORD-20260915-0B8W', NULL, 'confirmed', 'cod', 'pending', 210.00, 350.00, 21.00, 539.00, 'Test', 'Shopper', 'shopper@example.com', '09171234567', '123 Minimalist St', NULL, 'Makati', 'Metro Manila', NULL, NULL, '2026-09-14 20:44:03', '2026-09-14 20:44:03'),
(5, 'ORD-20260915-A3GL', NULL, 'confirmed', 'cod', 'pending', 1340.00, 350.00, 0.00, 1690.00, 'Demo', 'Customer', 'customer@smartspace.local', '+63 90541613231', 'asdasd', 'asdasd', 'asdasd', 'Metro Manila', '6545', 'asdasdasd', '2026-09-14 21:17:32', '2026-09-14 21:17:32'),
(6, 'ORD-20260915-5ILV', NULL, 'confirmed', 'cod', 'pending', 849.00, 350.00, 0.00, 1199.00, 'Demo', 'Customer', 'customer@smartspace.local', '+63 90541613231', 'asdasd', 'asdasd', 'asdasd', 'Metro Manila', '6545', 'asdasdasd', '2026-09-14 21:18:18', '2026-09-14 21:18:18');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `furniture_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `unit_price` decimal(12,2) NOT NULL,
  `total_price` decimal(12,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `furniture_id`, `quantity`, `unit_price`, `total_price`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 2, 849.00, 1698.00, '2026-09-14 20:36:55', '2026-09-14 20:36:55'),
(2, 2, 1, 2, 849.00, 1698.00, '2026-09-14 20:37:06', '2026-09-14 20:37:06'),
(3, 3, 1, 2, 849.00, 1698.00, '2026-09-14 20:37:16', '2026-09-14 20:37:16'),
(4, 4, 36, 1, 210.00, 210.00, '2026-09-14 20:44:03', '2026-09-14 20:44:03'),
(5, 5, 40, 1, 260.00, 260.00, '2026-09-14 21:17:32', '2026-09-14 21:17:32'),
(6, 5, 39, 2, 540.00, 1080.00, '2026-09-14 21:17:32', '2026-09-14 21:17:32'),
(7, 6, 1, 1, 849.00, 849.00, '2026-09-14 21:18:18', '2026-09-14 21:18:18');

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 2, 'smartspace_auth', '92e6b2a76a1d76a350fa40b838ec7199b13d56b7a7a835d97e9f00454b4eb386', '[\"*\"]', '2026-09-15 04:12:37', NULL, '2026-09-12 04:57:21', '2026-09-15 04:12:37'),
(2, 'App\\Models\\User', 2, 'test_rec', '6d14fe463a35a22680778464fe672af05c444845b44f9ab707feb98be3ac2ccf', '[\"*\"]', '2026-09-12 05:22:49', NULL, '2026-09-12 05:22:49', '2026-09-12 05:22:49'),
(3, 'App\\Models\\User', 2, 'test_rec', '8850c8fa18ab19782d92d3d9f77092609927e6924e2fc2043636b77e73d1e444', '[\"*\"]', '2026-09-12 05:23:01', NULL, '2026-09-12 05:23:01', '2026-09-12 05:23:01'),
(4, 'App\\Models\\User', 2, 'verify_token', 'b2a16bf595d9b326e9eee2d3f7a0e71b289625e16ce45b13b451447f4ed6517e', '[\"*\"]', '2026-09-12 06:40:14', NULL, '2026-09-12 06:40:14', '2026-09-12 06:40:14'),
(5, 'App\\Models\\User', 9, 'smartspace_auth', '210805788fe8397c59141885c87358efdbc4a3c6f5efada057cb5cb368decc38', '[\"*\"]', '2026-09-12 07:42:10', NULL, '2026-09-12 07:42:10', '2026-09-12 07:42:10'),
(6, 'App\\Models\\User', 9, 'smartspace_auth', 'de25e56aaed43c919db2b848b670296757d443b0ab2a393c1782377cffc365cf', '[\"*\"]', NULL, NULL, '2026-09-12 07:42:10', '2026-09-12 07:42:10'),
(7, 'App\\Models\\User', 2, 'test_token', '00bbbb0b4b0bc391936b3aae6ac09e36aa0b6128c90c6070bf70c5c91c1319c3', '[\"*\"]', '2026-09-12 07:42:11', NULL, '2026-09-12 07:42:11', '2026-09-12 07:42:11'),
(8, 'App\\Models\\User', 2, 'test_token_fav', 'e6b42d6fd64f15c85c1924f2a66b61d53ca6a477167d5ef2827787d889327d4e', '[\"*\"]', '2026-09-12 07:42:11', NULL, '2026-09-12 07:42:11', '2026-09-12 07:42:11'),
(9, 'App\\Models\\User', 13, 'smartspace_auth', '130cef7367fd41135184b8f231326f1be7b370201aa5c258b3ca3faecf627dc8', '[\"*\"]', '2026-09-12 07:44:15', NULL, '2026-09-12 07:44:15', '2026-09-12 07:44:15'),
(10, 'App\\Models\\User', 13, 'smartspace_auth', '68f5932471bd6607e823c08651e89ff102fdf6bd9af21b4cc6c6de50cf0ec5c2', '[\"*\"]', NULL, NULL, '2026-09-12 07:44:15', '2026-09-12 07:44:15'),
(11, 'App\\Models\\User', 2, 'test_token', 'f70a652056163f4fb58b74b2863697c45702d2f87b1d31d54bf356b1f0b44aee', '[\"*\"]', '2026-09-12 07:44:15', NULL, '2026-09-12 07:44:15', '2026-09-12 07:44:15'),
(12, 'App\\Models\\User', 2, 'test_token_fav', '284ada71006a6c8ca3e79d09b11440663c82638005a6bb090a17b025873b441f', '[\"*\"]', '2026-09-12 07:44:15', NULL, '2026-09-12 07:44:15', '2026-09-12 07:44:15'),
(13, 'App\\Models\\User', 17, 'smartspace_auth', '05a3b387ca855e2ea8bb86342d062418c43dcc14ed09074c0900774cd7cc7049', '[\"*\"]', '2026-09-12 19:13:36', NULL, '2026-09-12 19:13:36', '2026-09-12 19:13:36'),
(14, 'App\\Models\\User', 17, 'smartspace_auth', '5ee15e81617c08453d2a6accbe9a867e117b1bffefb72ae3ffb1929a147af988', '[\"*\"]', NULL, NULL, '2026-09-12 19:13:36', '2026-09-12 19:13:36'),
(15, 'App\\Models\\User', 2, 'test_token', '5b290ddd74d7e57441013fea707569283fea593408cec2377d6a9b7de327b941', '[\"*\"]', '2026-09-12 19:13:37', NULL, '2026-09-12 19:13:37', '2026-09-12 19:13:37'),
(16, 'App\\Models\\User', 2, 'test_token_fav', '3bae3ef09cbc02d5b8cb2f5c8f27e29ed2d3d283f193fa89f841bb720563f3fe', '[\"*\"]', '2026-09-12 19:13:37', NULL, '2026-09-12 19:13:37', '2026-09-12 19:13:37'),
(17, 'App\\Models\\User', 21, 'smartspace_auth', 'f7a1674df8fc1799f28b1db87f30e814b235502a946504e468fa3cbb9bb61a47', '[\"*\"]', '2026-09-14 20:37:15', NULL, '2026-09-14 20:37:15', '2026-09-14 20:37:15'),
(18, 'App\\Models\\User', 21, 'smartspace_auth', 'ca5e2c44c0c891014d3150269ad237925579aa3121172f77625f2e852af8f49e', '[\"*\"]', NULL, NULL, '2026-09-14 20:37:15', '2026-09-14 20:37:15'),
(19, 'App\\Models\\User', 2, 'test_token', 'f8f3bc0e241b8bfa64d4a289e3d286f12b2f01930af0d1e5d2615deca2c99ad3', '[\"*\"]', '2026-09-14 20:37:15', NULL, '2026-09-14 20:37:15', '2026-09-14 20:37:15'),
(20, 'App\\Models\\User', 2, 'test_token_fav', '6d51e4c5e77c9d94c704bdaec2c98e6cde26a89a7d0e465cbcdd49d493412b58', '[\"*\"]', '2026-09-14 20:37:16', NULL, '2026-09-14 20:37:16', '2026-09-14 20:37:16');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `slug`, `description`, `created_at`, `updated_at`) VALUES
(1, 'Administrator', 'admin', 'System administrator with full catalog and system management access.', '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(2, 'Customer', 'customer', 'Standard user who can design rooms, save projects, and favorite furniture.', '2026-09-12 04:57:01', '2026-09-12 04:57:01');

-- --------------------------------------------------------

--
-- Table structure for table `room_analyses`
--

CREATE TABLE `room_analyses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `room_project_id` bigint(20) UNSIGNED DEFAULT NULL,
  `image_path` varchar(255) NOT NULL,
  `detected_room_type` varchar(255) DEFAULT NULL,
  `detected_style` varchar(255) DEFAULT NULL,
  `detected_colors` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`detected_colors`)),
  `detected_objects` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`detected_objects`)),
  `confidence` decimal(4,3) NOT NULL DEFAULT 0.000,
  `ai_provider` varchar(255) NOT NULL DEFAULT 'mock',
  `raw_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`raw_response`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `room_analyses`
--

INSERT INTO `room_analyses` (`id`, `user_id`, `room_project_id`, `image_path`, `detected_room_type`, `detected_style`, `detected_colors`, `detected_objects`, `confidence`, `ai_provider`, `raw_response`, `created_at`, `updated_at`) VALUES
(1, 2, 1, 'analyses/4UkKv1BLFxKr1RY3k7LsyxMWmtT6kxd7Cpq2oMfW.webp', 'living_room', 'Industrial', '[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"living_room\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 05:25:29', '2026-09-12 05:25:29'),
(2, 2, 1, 'analyses/GA9CpPthHtuiaZAoIWVTpRTy0OtzKUZxd5vqfWHQ.webp', 'living_room', 'Industrial', '[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"living_room\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 05:27:17', '2026-09-12 05:27:17'),
(3, 2, 1, 'analyses/3uzz0ncKF8dKaHmJjRXukjrNhUoqHSdMfif9jg8k.webp', 'living_room', 'Industrial', '[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"living_room\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 05:30:38', '2026-09-12 05:30:38'),
(4, 2, 1, 'analyses/ZsjCyxGFYK5cAbWAqApCNP9KpqvcO0CpcxjQU7wP.webp', 'Living Room', 'Industrial', '[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"Living Room\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 05:30:42', '2026-09-12 05:30:42'),
(5, 2, 1, 'analyses/HW3PgjAQIDSzP0Dcy6VeYtPhku1ABXY4VrpwW56b.webp', 'Living Room', 'Industrial', '[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"Living Room\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 05:30:44', '2026-09-12 05:30:44'),
(6, 2, 1, 'analyses/FVyeX1kpL6SNX6HZzVEiH08F5U2gU0JRrcRmWZBM.webp', 'Living Room', 'Industrial', '[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"Living Room\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 05:30:45', '2026-09-12 05:30:45'),
(7, 2, 1, 'analyses/l9VSwWVeAaOmzLM7LO35IkmlJVU9NNLgC9ewT0zH.webp', 'Living Room', 'Industrial', '[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"Living Room\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 05:30:48', '2026-09-12 05:30:48'),
(8, 2, 1, 'analyses/K5KuVwWgqPUY58EvMReqE1RE5uzMTwrM8I6dAnI7.webp', 'Living Room', 'Industrial', '[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"Living Room\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 05:30:48', '2026-09-12 05:30:48'),
(10, 2, 1, 'analyses/Wy4Ge26ED0u3wIB5F7wxD254YFf1NuI85eCvnkjH.webp', 'living_room', 'Industrial', '[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"living_room\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 07:11:39', '2026-09-12 07:11:39'),
(11, 2, 1, 'analyses/xpz3WVdrtKMuldQYGEC34rv8WdMKQQ0oeIMuiTgk.webp', 'living_room', 'Industrial', '[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"living_room\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 07:11:42', '2026-09-12 07:11:42'),
(12, 2, 1, 'analyses/jXNwxXcdM6jogwlMyLZmkLwmzYj1aQbTKXMeXCG8.webp', 'living_room', 'Industrial', '[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"living_room\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 07:11:48', '2026-09-12 07:11:48'),
(13, 2, 1, 'analyses/XsMIZRBlOLILDdi6tEfDox5MA7weOn2CYObe9TGP.webp', 'Bedroom', 'Industrial', '[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"Bedroom\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#010101\",\"#A09B94\",\"#9A958D\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 07:11:52', '2026-09-12 07:11:52'),
(14, 2, 1, 'analyses/oIZSfYlfzQ7Xs8lgn26NP0uC6o1E3AoxwSUbKRkr.png', 'Bedroom', 'Industrial', '[\"#000000\",\"#020303\",\"#5C5C5C\",\"#0C393C\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"Bedroom\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#020303\",\"#5C5C5C\",\"#0C393C\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 07:11:56', '2026-09-12 07:11:56'),
(15, 2, 1, 'analyses/PcnTpzYS1QZSxV2w4kd8K5recBCEpuEJWQhhFMOJ.png', 'Bedroom', 'Industrial', '[\"#000000\",\"#020303\",\"#5C5C5C\",\"#0C393C\"]', '[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"]', 0.820, 'rule_based', '{\"detected_room_type\":\"Bedroom\",\"detected_style\":\"Industrial\",\"dominant_colors\":[\"#000000\",\"#020303\",\"#5C5C5C\",\"#0C393C\"],\"detected_objects\":[\"Image color clusters\",\"Ambient luminance profile\",\"Base boundary\"],\"visual_clutter\":\"Medium\",\"confidence\":0.82,\"provider\":\"rule_based\",\"is_mock\":false,\"summary\":\"Rule-based heuristic perception: Quantized dominant palette from image histogram. Detected Industrial stylistic tendency based on luminance and color saturation metrics.\"}', '2026-09-12 07:11:57', '2026-09-12 07:11:57');

-- --------------------------------------------------------

--
-- Table structure for table `room_projects`
--

CREATE TABLE `room_projects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `room_type` varchar(255) NOT NULL,
  `width_cm` decimal(8,2) NOT NULL,
  `length_cm` decimal(8,2) NOT NULL,
  `height_cm` decimal(8,2) NOT NULL DEFAULT 260.00,
  `style` varchar(255) DEFAULT NULL,
  `room_image_path` varchar(255) DEFAULT NULL,
  `compatibility_score` decimal(5,2) DEFAULT NULL,
  `score_breakdown` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`score_breakdown`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `room_projects`
--

INSERT INTO `room_projects` (`id`, `user_id`, `name`, `room_type`, `width_cm`, `length_cm`, `height_cm`, `style`, `room_image_path`, `compatibility_score`, `score_breakdown`, `created_at`, `updated_at`) VALUES
(1, 2, 'Nordic Living Room Concept', 'living_room', 420.00, 500.00, 260.00, 'scandinavian', NULL, 100.00, '{\"total_score\":100,\"is_valid\":true,\"verdict\":\"Excellent Fit\",\"badge\":\"\\ud83d\\udfe2\",\"description\":\"Optimal furniture arrangement with generous walking circulation and complete clearance compliance.\",\"room_dimensions\":{\"width_m\":4.2,\"length_m\":5,\"height_m\":2.6,\"area_sqm\":21},\"item_count\":4,\"breakdown\":{\"boundary_fit\":{\"score\":30,\"max\":30,\"status\":\"pass\",\"violation_count\":0,\"violations\":[]},\"collision\":{\"score\":25,\"max\":25,\"status\":\"pass\",\"collision_count\":0,\"collisions\":[]},\"clearance\":{\"score\":25,\"max\":25,\"status\":\"pass\",\"warning_count\":0,\"warnings\":[]},\"utilization\":{\"score\":10,\"max\":10,\"walking_ratio\":0.8049,\"occupied_percentage\":19.5,\"room_area_sqm\":21,\"furniture_area_sqm\":4.1,\"status\":\"excellent\"},\"room_fitness\":{\"score\":10,\"max\":10,\"matched_items\":4,\"total_items\":4,\"status\":\"pass\",\"unmatched\":[]}},\"evaluation_notes\":\"All items safely contained within room perimeter. Zero collision overlaps. Full front and side clearance corridors maintained. Space utilization: 19.5% occupied (excellent circulation).\"}', '2026-09-12 04:57:01', '2026-09-12 07:44:01'),
(5, 2, 'Scenario A — High Compliance Living Room', 'living_room', 420.00, 500.00, 280.00, 'scandinavian', NULL, 100.00, '{\"total_score\":100,\"is_valid\":true,\"verdict\":\"Excellent Fit\",\"badge\":\"\\ud83d\\udfe2\",\"description\":\"Optimal furniture arrangement with generous walking circulation and complete clearance compliance.\",\"room_dimensions\":{\"width_m\":4.2,\"length_m\":5,\"height_m\":2.8,\"area_sqm\":21},\"item_count\":5,\"breakdown\":{\"boundary_fit\":{\"score\":30,\"max\":30,\"status\":\"pass\",\"violation_count\":0,\"violations\":[]},\"collision\":{\"score\":25,\"max\":25,\"status\":\"pass\",\"collision_count\":0,\"collisions\":[]},\"clearance\":{\"score\":25,\"max\":25,\"status\":\"pass\",\"warning_count\":0,\"warnings\":[]},\"utilization\":{\"score\":10,\"max\":10,\"walking_ratio\":0.803,\"occupied_percentage\":19.7,\"room_area_sqm\":21,\"furniture_area_sqm\":4.14,\"status\":\"excellent\"},\"room_fitness\":{\"score\":10,\"max\":10,\"matched_items\":5,\"total_items\":5,\"status\":\"pass\",\"unmatched\":[]}},\"evaluation_notes\":\"All items safely contained within room perimeter. Zero collision overlaps. Full front and side clearance corridors maintained. Space utilization: 19.7% occupied (excellent circulation).\"}', '2026-09-12 07:35:22', '2026-09-12 07:38:19'),
(6, 2, 'Scenario B — Conflict & Recovery Demo', 'living_room', 300.00, 320.00, 260.00, 'industrial', NULL, 29.00, '{\"total_score\":29,\"is_valid\":false,\"verdict\":\"Does Not Fit\",\"badge\":\"\\ud83d\\udd34\",\"description\":\"Items collide or extend beyond room boundaries. Layout adjustment required.\",\"room_dimensions\":{\"width_m\":3,\"length_m\":3.2,\"height_m\":2.6,\"area_sqm\":9.6},\"item_count\":2,\"breakdown\":{\"boundary_fit\":{\"score\":0,\"max\":30,\"status\":\"fail\",\"violation_count\":1,\"violations\":[{\"sku\":\"SOFA-003\",\"name\":\"Manhattan L-Shaped Sectional Sofa\",\"breaches\":{\"east_wall_breach_m\":1},\"message\":\"Item \'Manhattan L-Shaped Sectional Sofa\' exceeds the perimeter walls of the room.\"}]},\"collision\":{\"score\":0,\"max\":25,\"status\":\"fail\",\"collision_count\":1,\"collisions\":[{\"item_a\":{\"sku\":\"SOFA-003\",\"name\":\"Manhattan L-Shaped Sectional Sofa\"},\"item_b\":{\"sku\":\"DTB-001\",\"name\":\"Circa 4-Seater Round Dining Table\"},\"overlap_type\":\"3D AABB Intersection\",\"message\":\"Physical collision detected between \'Manhattan L-Shaped Sectional Sofa\' and \'Circa 4-Seater Round Dining Table\'.\"}]},\"clearance\":{\"score\":19,\"max\":25,\"status\":\"warning\",\"warning_count\":2,\"warnings\":[{\"sku\":\"SOFA-003\",\"name\":\"Manhattan L-Shaped Sectional Sofa\",\"required_clearance_m\":0.9,\"available_clearance_m\":0.54,\"deficit_m\":0.36,\"penalty_pts\":2,\"message\":\"Front clearance zone for \'Manhattan L-Shaped Sectional Sofa\' is restricted (available: 54 cm, required: 90 cm).\"},{\"sku\":\"DTB-001\",\"name\":\"Circa 4-Seater Round Dining Table\",\"required_clearance_m\":0.8,\"available_clearance_m\":0.16,\"deficit_m\":0.64,\"penalty_pts\":4,\"message\":\"Front clearance zone for \'Circa 4-Seater Round Dining Table\' is restricted (available: 16 cm, required: 80 cm).\"}]},\"utilization\":{\"score\":5,\"max\":10,\"walking_ratio\":0.3927,\"occupied_percentage\":60.7,\"room_area_sqm\":9.6,\"furniture_area_sqm\":5.83,\"status\":\"tight\"},\"room_fitness\":{\"score\":5,\"max\":10,\"matched_items\":1,\"total_items\":2,\"status\":\"warning\",\"unmatched\":[{\"sku\":\"DTB-001\",\"name\":\"Circa 4-Seater Round Dining Table\",\"category\":\"dining-tables\",\"message\":\"Item \'Circa 4-Seater Round Dining Table\' (dining-tables) is atypical for a living_room.\"}]}},\"evaluation_notes\":\"Boundary breach: 1 item(s) exceed room boundaries. Overlap detected: 1 furniture collision(s). 2 clearance warning(s) detected. Space utilization: 60.7% occupied (tight circulation).\"}', '2026-09-12 07:35:22', '2026-09-12 07:35:22'),
(7, 2, 'Scenario C — AI Vision Sandbox', 'living_room', 400.00, 500.00, 280.00, 'scandinavian', NULL, NULL, NULL, '2026-09-12 07:35:39', '2026-09-12 07:35:39');

-- --------------------------------------------------------

--
-- Table structure for table `room_project_furniture`
--

CREATE TABLE `room_project_furniture` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `room_project_id` bigint(20) UNSIGNED NOT NULL,
  `furniture_id` bigint(20) UNSIGNED NOT NULL,
  `position_x` decimal(8,4) NOT NULL DEFAULT 0.0000,
  `position_y` decimal(8,4) NOT NULL DEFAULT 0.0000,
  `position_z` decimal(8,4) NOT NULL DEFAULT 0.0000,
  `rotation_y` decimal(8,4) NOT NULL DEFAULT 0.0000,
  `scale` decimal(5,3) NOT NULL DEFAULT 1.000,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `room_project_furniture`
--

INSERT INTO `room_project_furniture` (`id`, `room_project_id`, `furniture_id`, `position_x`, `position_y`, `position_z`, `rotation_y`, `scale`, `created_at`, `updated_at`) VALUES
(10, 1, 1, 0.0000, 0.0000, -1.2000, 0.0000, 1.000, '2026-09-12 05:12:08', '2026-09-12 05:12:08'),
(11, 1, 7, 0.0000, 0.0000, 0.2000, 0.0000, 1.000, '2026-09-12 05:12:08', '2026-09-12 05:12:08'),
(12, 1, 12, 0.0000, 0.0000, 1.8000, 180.0000, 1.000, '2026-09-12 05:12:08', '2026-09-12 05:12:08'),
(13, 1, 39, -1.2500, 0.0000, 0.4000, 60.0000, 1.000, '2026-09-12 05:12:08', '2026-09-12 07:44:01'),
(45, 5, 1, 0.0000, 0.0000, -1.6000, 0.0000, 1.000, '2026-09-12 07:38:19', '2026-09-12 07:38:19'),
(46, 5, 7, 0.0000, 0.0000, 0.1000, 0.0000, 1.000, '2026-09-12 07:38:19', '2026-09-12 07:38:19'),
(47, 5, 11, 0.0000, 0.0000, 2.0000, 180.0000, 1.000, '2026-09-12 07:38:19', '2026-09-12 07:38:19'),
(48, 5, 9, 1.5500, 0.0000, -1.6000, 0.0000, 1.000, '2026-09-12 07:38:19', '2026-09-12 07:38:19'),
(49, 5, 37, -1.8000, 0.0000, 0.0000, 90.0000, 1.000, '2026-09-12 07:38:19', '2026-09-12 07:38:19'),
(50, 6, 3, 1.1000, 0.0000, 0.4000, 0.0000, 1.000, '2026-09-12 07:38:19', '2026-09-12 07:38:19'),
(51, 6, 28, 0.6000, 0.0000, 0.4000, 0.0000, 1.000, '2026-09-12 07:38:19', '2026-09-12 07:38:19');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `role_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `role_id`, `name`, `email`, `email_verified_at`, `password`, `avatar`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 1, 'SmartSpace Admin', 'admin@smartspace.local', '2026-09-12 04:57:01', '$2y$12$Fw1AyHyY/1vnDQEMAdFeUeIUXyjLX8jPk9wgCkD5OZRxwNlohLUse', NULL, NULL, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(2, 2, 'Demo Customer', 'customer@smartspace.local', '2026-09-12 04:57:01', '$2y$12$YJUQK4hEmWvasOWRFpxMVeZArLYXz6D2aoyOdbH0hCSUWuo.x.cLy', NULL, NULL, '2026-09-12 04:57:01', '2026-09-12 04:57:01'),
(9, 2, 'Test Spatial Architect', 'architect_6aa572d243081@smartspace.local', NULL, '$2y$04$uS9Hciv.Lx0yK557Lc/Ib.pjN75oBCfRICPfPU89cRO88neCx1kpK', NULL, NULL, '2026-09-12 07:42:10', '2026-09-12 07:42:10'),
(13, 2, 'Test Spatial Architect', 'architect_6aa5734f67b9d@smartspace.local', NULL, '$2y$04$G1FblLgOhgsDwbzCedM7be77/bwwVImdtQLyujCAv59eWKRfIBxlK', NULL, NULL, '2026-09-12 07:44:15', '2026-09-12 07:44:15'),
(17, 2, 'Test Spatial Architect', 'architect_6aa614e019043@smartspace.local', NULL, '$2y$04$OC99fgcnhxTdql0KBUxkrOG30J.W60N61yrMwvD6N/i2/.p7PfKOS', NULL, NULL, '2026-09-12 19:13:36', '2026-09-12 19:13:36'),
(21, 2, 'Test Spatial Architect', 'architect_6aa8cb7b52ed8@smartspace.local', NULL, '$2y$04$obHC6e1RID8ue46h1A/0zO/NlWfazYUQDfiOhjeuM0AuET7s2/ZKG', NULL, NULL, '2026-09-14 20:37:15', '2026-09-14 20:37:15');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `categories_slug_unique` (`slug`),
  ADD KEY `categories_parent_id_foreign` (`parent_id`);

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `favorites_user_id_furniture_id_unique` (`user_id`,`furniture_id`),
  ADD KEY `favorites_furniture_id_foreign` (`furniture_id`);

--
-- Indexes for table `furniture`
--
ALTER TABLE `furniture`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `furniture_sku_unique` (`sku`),
  ADD KEY `furniture_category_id_foreign` (`category_id`),
  ADD KEY `furniture_style_index` (`style`),
  ADD KEY `furniture_price_index` (`price`);

--
-- Indexes for table `furniture_images`
--
ALTER TABLE `furniture_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `furniture_images_furniture_id_foreign` (`furniture_id`);

--
-- Indexes for table `furniture_models`
--
ALTER TABLE `furniture_models`
  ADD PRIMARY KEY (`id`),
  ADD KEY `furniture_models_furniture_id_foreign` (`furniture_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `orders_order_number_unique` (`order_number`),
  ADD KEY `orders_user_id_foreign` (`user_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_order_id_foreign` (`order_id`),
  ADD KEY `order_items_furniture_id_foreign` (`furniture_id`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `roles_slug_unique` (`slug`);

--
-- Indexes for table `room_analyses`
--
ALTER TABLE `room_analyses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `room_analyses_user_id_foreign` (`user_id`),
  ADD KEY `room_analyses_room_project_id_foreign` (`room_project_id`);

--
-- Indexes for table `room_projects`
--
ALTER TABLE `room_projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `room_projects_user_id_foreign` (`user_id`);

--
-- Indexes for table `room_project_furniture`
--
ALTER TABLE `room_project_furniture`
  ADD PRIMARY KEY (`id`),
  ADD KEY `room_project_furniture_room_project_id_foreign` (`room_project_id`),
  ADD KEY `room_project_furniture_furniture_id_foreign` (`furniture_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD KEY `users_role_id_foreign` (`role_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `furniture`
--
ALTER TABLE `furniture`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT for table `furniture_images`
--
ALTER TABLE `furniture_images`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `furniture_models`
--
ALTER TABLE `furniture_models`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=80;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `room_analyses`
--
ALTER TABLE `room_analyses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `room_projects`
--
ALTER TABLE `room_projects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `room_project_furniture`
--
ALTER TABLE `room_project_furniture`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `categories_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `favorites`
--
ALTER TABLE `favorites`
  ADD CONSTRAINT `favorites_furniture_id_foreign` FOREIGN KEY (`furniture_id`) REFERENCES `furniture` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `favorites_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `furniture`
--
ALTER TABLE `furniture`
  ADD CONSTRAINT `furniture_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `furniture_images`
--
ALTER TABLE `furniture_images`
  ADD CONSTRAINT `furniture_images_furniture_id_foreign` FOREIGN KEY (`furniture_id`) REFERENCES `furniture` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `furniture_models`
--
ALTER TABLE `furniture_models`
  ADD CONSTRAINT `furniture_models_furniture_id_foreign` FOREIGN KEY (`furniture_id`) REFERENCES `furniture` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_furniture_id_foreign` FOREIGN KEY (`furniture_id`) REFERENCES `furniture` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `room_analyses`
--
ALTER TABLE `room_analyses`
  ADD CONSTRAINT `room_analyses_room_project_id_foreign` FOREIGN KEY (`room_project_id`) REFERENCES `room_projects` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `room_analyses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `room_projects`
--
ALTER TABLE `room_projects`
  ADD CONSTRAINT `room_projects_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `room_project_furniture`
--
ALTER TABLE `room_project_furniture`
  ADD CONSTRAINT `room_project_furniture_furniture_id_foreign` FOREIGN KEY (`furniture_id`) REFERENCES `furniture` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `room_project_furniture_room_project_id_foreign` FOREIGN KEY (`room_project_id`) REFERENCES `room_projects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
