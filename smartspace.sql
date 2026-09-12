-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 12, 2026 at 09:43 AM
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
(1, NULL, 'Living Room', 'living-room', 'Furniture and accessories for communal lounging and living spaces.', 'couch', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(2, 1, 'Sofas & Lounging', 'sofas-lounging', '2-seaters, 3-seaters, modular sectionals, and daybeds.', 'sofa', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(3, 1, 'Coffee & Side Tables', 'coffee-side-tables', 'Low central tables, nesting sets, and side tables.', 'table', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(4, 1, 'Media & TV Units', 'media-tv-units', 'Entertainment centers, credenzas, and media benches.', 'tv', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(5, 1, 'Accent & Storage Units', 'accent-storage', 'Bookcases, room dividers, armchairs, and entryway units.', 'archive', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(6, NULL, 'Bedroom', 'bedroom', 'Bedframes, storage beds, and nightstands for sleeping quarters.', 'bed', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(7, 6, 'Beds & Mattresses', 'beds-mattresses', 'Single, queen, king, and platform storage beds.', 'bed-double', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(8, 6, 'Nightstands & Bedside Storage', 'nightstands', 'Compact bedside drawers, floating shelves, and nightstands.', 'clock', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(9, NULL, 'Home Office', 'home-office', 'Desks, computer workstations, and ergonomic workspace furniture.', 'laptop', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(10, 9, 'Desks & Workstations', 'desks-workstations', 'Compact writing desks, executive desks, and sit-stand desks.', 'briefcase', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(11, NULL, 'Dining', 'dining', 'Dining tables and chairs for meals and entertaining.', 'utensils', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(12, 11, 'Dining Tables', 'dining-tables', 'Circular, rectangular, and extendable dining tables.', 'table-restaurant', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(13, 11, 'Dining Chairs', 'dining-chairs', 'Ergonomic, upholstered, and minimalist dining seating.', 'chair', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33');

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
(1, 2, 1, '2026-09-12 01:25:33'),
(2, 2, 12, '2026-09-12 01:25:33'),
(3, 2, 25, '2026-09-12 01:25:33');

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
(1, 2, 'SOFA-001', 'Nordik 3-Seater Minimalist Sofa', 'Tailored three-seater sofa featuring clean architectural lines, high-density resilience foam, and tapered solid ash legs.', 849.00, 210.00, 82.00, 88.00, 80.00, 50.00, 'scandinavian', 'Linen Fabric & Ash Wood', 'Warm Grey', '#A8A6A1', '/storage/furniture/models/SOFA-001.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(2, 2, 'SOFA-002', 'Loft 2-Seater Compact Studio Sofa', 'Compact deep-seat loveseat ideal for urban apartments and smaller living spaces, upholstered in tactile boucle.', 580.00, 152.00, 78.00, 82.00, 70.00, 40.00, 'minimalist', 'Boucle Fabric', 'Cream White', '#F3EFEA', '/storage/furniture/models/SOFA-002.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(3, 2, 'SOFA-003', 'Manhattan L-Shaped Sectional Sofa', 'Generous family-sized corner sectional with right-hand chaise, wrapped in hand-finished top-grain saddle leather.', 1850.00, 280.00, 84.00, 165.00, 90.00, 60.00, 'modern', 'Top-Grain Leather', 'Cognac Brown', '#8B4513', '/storage/furniture/models/SOFA-003.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(4, 2, 'SOFA-004', 'Ironworks Industrial Tufted Loveseat', 'Rugged industrial loveseat pairing distressed caramel leather cushions with a welded blackened steel frame.', 920.00, 165.00, 80.00, 86.00, 75.00, 50.00, 'industrial', 'Aged Leather & Black Steel', 'Charcoal Brown', '#3E3430', '/storage/furniture/models/SOFA-004.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(5, 2, 'SOFA-005', 'Kyoto Low Platform Daybed', 'Zen-inspired minimalist daybed with an oiled American walnut frame and a supportive natural cotton futon cushion.', 740.00, 195.00, 65.00, 80.00, 70.00, 40.00, 'minimalist', 'Natural Walnut & Cotton', 'Sand Beige', '#D2B48C', '/storage/furniture/models/SOFA-005.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(6, 2, 'SOFA-006', 'Chesterfield Heritage 3-Seater', 'Classic rolled-arm sofa featuring deep button-tufted upholstery in rich jewel-tone velvet.', 1450.00, 225.00, 76.00, 92.00, 85.00, 60.00, 'classic', 'Deep Buttoned Velvet', 'Forest Green', '#1E3F20', '/storage/furniture/models/SOFA-006.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(7, 3, 'COFF-001', 'Aura Oval Glass & Oak Coffee Table', 'Organic oval silhouette featuring a floating tempered glass surface resting on a sculptural solid white oak base.', 290.00, 110.00, 42.00, 60.00, 50.00, 50.00, 'scandinavian', 'Tempered Glass & Solid Oak', 'Natural Oak', '#C8B195', '/storage/furniture/models/COFF-001.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(8, 3, 'COFF-002', 'Mono Block Minimalist Low Table', 'Architectural monolith table with a seamless micro-cement finish, grounding the living space in pure geometry.', 340.00, 90.00, 36.00, 90.00, 45.00, 45.00, 'minimalist', 'Micro-cement Finish', 'Matte Slate', '#4A5056', '/storage/furniture/models/COFF-002.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(9, 3, 'COFF-003', 'Factory Round Nesting Tables (Pair)', 'Two nesting circular accent tables crafted from reclaimed teak planks with hand-welded iron band frames.', 260.00, 80.00, 45.00, 80.00, 40.00, 40.00, 'industrial', 'Reclaimed Teak & Matte Black Iron', 'Distressed Teak', '#634735', '/storage/furniture/models/COFF-003.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(10, 3, 'COFF-004', 'Verona Marble Rectangular Coffee Table', 'Honed Italian Carrara marble slab mounted on an understated satin brass architectural underframe.', 620.00, 120.00, 40.00, 65.00, 50.00, 50.00, 'modern', 'Carrara Marble & Brass', 'Carrara White', '#F0EEE9', '/storage/furniture/models/COFF-004.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(11, 4, 'TV-001', 'Horizon 180 Floating Wall Console', 'Wall-mounted floating media unit with integrated cable raceway, push-to-open acoustic fabric drop-down fronts.', 420.00, 180.00, 32.00, 38.00, 80.00, 30.00, 'minimalist', 'Matte Lacquer & Oak Veneer', 'Arctic White / Oak', '#F8F8F8', '/storage/furniture/models/TV-001.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(12, 4, 'TV-002', 'Oslo Low Media Bench 200cm', 'Substantial Nordic entertainment credenza featuring tambour slatted sliding doors and wire-pass dividers.', 680.00, 200.00, 48.00, 45.00, 90.00, 40.00, 'scandinavian', 'Solid White Oak & Slatted Doors', 'Nordic Oak', '#DEC5A5', '/storage/furniture/models/TV-002.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(13, 4, 'TV-003', 'Brooklyn Steel-Mesh Credenza', 'Heavy-gauge steel frame with perforated mesh doors allowing remote control IR pass-through, topped with aged elm.', 540.00, 160.00, 60.00, 42.00, 75.00, 30.00, 'industrial', 'Perforated Steel & Elm Wood', 'Industrial Black', '#262626', '/storage/furniture/models/TV-003.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(14, 4, 'TV-004', 'Palais Walnut Sideboard Console', 'Substantial mid-century influenced sideboard with bookmatched walnut veneer and brushed antique brass pulls.', 890.00, 175.00, 75.00, 46.00, 80.00, 35.00, 'classic', 'American Walnut & Brass Knobs', 'Dark Walnut', '#442B15', '/storage/furniture/models/TV-004.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(15, 7, 'BED-001', 'Fjord Single Platform Bed (90x200)', 'Clean-lined solid birch bed frame designed for standard single 90x200 cm mattresses with integrated posture slats.', 380.00, 98.00, 90.00, 208.00, 60.00, 60.00, 'scandinavian', 'Solid Birch', 'Light Birch', '#E6DAC8', '/storage/furniture/models/BED-001.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(16, 7, 'BED-002', 'Astrid Queen Upholstered Bed (160x200)', 'Curved shelter headboard upholstered in durable heathered woven fabric with padded perimeter rails.', 790.00, 172.00, 110.00, 215.00, 75.00, 60.00, 'modern', 'Textured Woven Fabric & Foam', 'Muted Sand', '#D7CEC7', '/storage/furniture/models/BED-002.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(17, 7, 'BED-003', 'Skan King Hydraulic Storage Bed (180x200)', 'Effortless gas-lift hydraulic mechanism revealing cavernous under-bed storage without sacrificing clean Nordic aesthetics.', 1150.00, 194.00, 105.00, 216.00, 80.00, 65.00, 'scandinavian', 'Oak Veneer with Gas-Lift Storage', 'Natural Oak', '#C2A382', '/storage/furniture/models/BED-003.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(18, 7, 'BED-004', 'Zen Low Tatami Platform King (180x200)', 'Ultra-low Japanese minimalist platform bed with an extended perimeter ledge crafted from sustainably harvested cedar.', 690.00, 210.00, 30.00, 220.00, 60.00, 50.00, 'minimalist', 'Solid Cedar & Ash', 'Raw Wood', '#CEB89E', '/storage/furniture/models/BED-004.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(19, 7, 'BED-005', 'Grand Master Tufted King Bed (180x200)', 'High diamond-tufted linen headboard with handcrafted fluted posts for an elegant master bedroom aesthetic.', 1320.00, 196.00, 140.00, 222.00, 85.00, 70.00, 'classic', 'Padded Linen & Carved Wood', 'Oatmeal', '#E3DAC9', '/storage/furniture/models/BED-005.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(20, 8, 'NST-001', 'Aero Floating Bedside Shelf', 'Wall-hung curved nightstand with concealed soft-close drawer, keeping floor space completely open.', 95.00, 42.00, 18.00, 32.00, 50.00, 20.00, 'minimalist', 'Bent Ash Plywood', 'Natural Ash', '#DFD2C0', '/storage/furniture/models/NST-001.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(21, 8, 'NST-002', 'Linnea 2-Drawer Oak Nightstand', 'Classic Scandinavian bedside chest with dovetailed joinery and recessed brass finger pulls.', 165.00, 48.00, 54.00, 40.00, 55.00, 25.00, 'scandinavian', 'Solid Oak & Brass Pulls', 'Honey Oak', '#C99E6B', '/storage/furniture/models/NST-002.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(22, 8, 'NST-003', 'Foundry Open Wire Bedside Cube', 'Minimalist open-cage bedside locker featuring blackened iron mesh and a removable solid mango wood top.', 120.00, 40.00, 50.00, 38.00, 45.00, 20.00, 'industrial', 'Powder-coated Steel & Mango Wood', 'Matte Black', '#222222', '/storage/furniture/models/NST-003.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(23, 8, 'NST-004', 'Grace Fluted Cylinder Pedestal', 'Round architectural nightstand with textured fluted casing and an inset engineered white stone top.', 210.00, 38.00, 52.00, 38.00, 45.00, 20.00, 'modern', 'Fluted Ceramic & Marble Top', 'Ivory White', '#F5F5F0', '/storage/furniture/models/NST-004.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(24, 10, 'DSK-001', 'Solo Compact Study Desk 100x50', 'Slender workspace desk specifically proportioned for bedrooms and studio apartments with an integrated monitor shelf.', 185.00, 100.00, 75.00, 50.00, 80.00, 30.00, 'minimalist', 'Laminate & White Steel Frame', 'White / Birch', '#EBEAE6', '/storage/furniture/models/DSK-001.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(25, 10, 'DSK-002', 'ErgoPro Motorized Sit-Stand Desk 140x70', 'Dual-motor electric height-adjustable desk with memory presets, solid walnut desktop, and anti-collision sensor.', 580.00, 140.00, 72.00, 70.00, 90.00, 40.00, 'modern', 'Solid Walnut Top & Dual Motor Base', 'Warm Walnut', '#5C4033', '/storage/furniture/models/DSK-002.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(26, 10, 'DSK-003', 'Architect Drafting Studio Desk', 'Industrial drafting table with adjustable incline top, cast-iron crank wheels, and rustic pine timbers.', 440.00, 150.00, 76.00, 75.00, 85.00, 40.00, 'industrial', 'Cast Iron Trestles & Rustic Pine', 'Raw Pine / Cast Iron', '#876543', '/storage/furniture/models/DSK-003.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(27, 10, 'DSK-004', 'Executive L-Shaped Corner Workstation', 'Comprehensive executive desk providing generous desktop area and integrated lockable filing drawers.', 790.00, 180.00, 75.00, 140.00, 95.00, 50.00, 'modern', 'Smoked Oak & Charcoal Metal', 'Smoked Oak', '#3B332C', '/storage/furniture/models/DSK-004.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(28, 12, 'DTB-001', 'Circa 4-Seater Round Dining Table', 'Warm round solid ash table with conical pedestal base, maximizing knee clearance and intimacy in compact dining nooks.', 520.00, 110.00, 75.00, 110.00, 80.00, 80.00, 'scandinavian', 'Solid Ash with Pedestal Base', 'Blonde Ash', '#E2D3B8', '/storage/furniture/models/DTB-001.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(29, 12, 'DTB-002', 'Kanso 6-Seater Rectangular Dining Table', 'Pure minimalist dining table crafted from wide planks of solid European white oak with soft radius edges.', 740.00, 160.00, 76.00, 90.00, 85.00, 60.00, 'minimalist', 'Solid White Oak', 'Natural Oak', '#CCB290', '/storage/furniture/models/DTB-002.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(30, 12, 'DTB-003', 'Bastion 8-Seater Extendable Dining Table', 'Substantial live-edge walnut dining table with a butterfly internal extension mechanism expanding up to 260 cm.', 1180.00, 200.00, 76.00, 95.00, 90.00, 70.00, 'industrial', 'Live-Edge Walnut & U-Steel Legs', 'Deep Walnut', '#4A3525', '/storage/furniture/models/DTB-003.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(31, 13, 'DCH-001', 'Fawn Scandinavian Spindle Dining Chair', 'Timeless Windsor-inspired dining chair with turned beech spindles and a saddled ergonomic wooden seat.', 95.00, 46.00, 82.00, 49.00, 50.00, 20.00, 'scandinavian', 'Bentwood Beech', 'Natural Beech', '#D8C6A5', '/storage/furniture/models/DCH-001.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(32, 13, 'DCH-002', 'Port Upholstered Curved Back Armchair', 'Plush wrap-around curved back dining chair providing generous lumbar support during long dinner parties.', 155.00, 56.00, 78.00, 54.00, 55.00, 25.00, 'modern', 'Tweed Fabric & Matte Black Legs', 'Charcoal Grey', '#404040', '/storage/furniture/models/DCH-002.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(33, 13, 'DCH-003', 'Cantilever Chrome Leatherette Chair', 'Bauhaus-influenced S-curve tubular steel cantilever chair providing comfortable natural flex.', 130.00, 48.00, 84.00, 52.00, 50.00, 20.00, 'modern', 'Tubular Steel & Saddle Faux Leather', 'Caramel Brown', '#A0522D', '/storage/furniture/models/DCH-003.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(34, 13, 'DCH-004', 'Bento Minimalist Molded Shell Chair', 'Ultra-lightweight stackable molded polypropylene chair with matte texture and solid beech dowel legs.', 75.00, 48.00, 79.00, 47.00, 45.00, 20.00, 'minimalist', 'Recycled Polypropylene & Wood', 'Chalk White', '#F0EDE6', '/storage/furniture/models/DCH-004.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(35, 13, 'DCH-005', 'Bistro Wire Metal Dining Chair', 'Geometric wire grid chair with an electroplated gunmetal finish and a magnetic vegan leather seat cushion.', 88.00, 44.00, 80.00, 46.00, 45.00, 20.00, 'industrial', 'Welded Steel Rod with Leather Pad', 'Gunmetal Grey', '#33373B', '/storage/furniture/models/DCH-005.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(36, 13, 'DCH-006', 'Heritage Oak Dining Bench 140cm', 'Sturdy solid oak bench that slides completely under 160+ cm dining tables when not in active use.', 210.00, 140.00, 46.00, 36.00, 40.00, 20.00, 'scandinavian', 'Solid Oak with Rounded Edges', 'Natural Oak', '#CDB18B', '/storage/furniture/models/DCH-006.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(37, 5, 'STG-001', 'Gridline Tall Open Modular Bookcase', 'Architectural steel frame bookcase featuring 5 staggered shelves of natural ash, perfect for room zoning.', 340.00, 90.00, 190.00, 34.00, 70.00, 25.00, 'minimalist', 'Powder-coated Steel & Ash Shelves', 'Matte Black & Ash', '#2A2927', '/storage/furniture/models/STG-001.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(38, 5, 'STG-002', 'Lattice Timber Room Divider / Screen', 'Freestanding vertical timber slat screen with an integrated planter box for creating privacy and zones in open plans.', 390.00, 120.00, 175.00, 30.00, 60.00, 30.00, 'scandinavian', 'Vertical Oak Slats & Planter Box', 'Nordic Oak', '#D5BE9E', '/storage/furniture/models/STG-002.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(39, 5, 'STG-003', 'Hygge Cocoon Reading Armchair', 'Comfortable reading accent chair upholstered in plush shearling fleece with a 360-degree silent swivel oak base.', 540.00, 84.00, 92.00, 82.00, 75.00, 40.00, 'scandinavian', 'Shearling Fleece & Oak Swivel Base', 'Warm Oatmeal', '#EAE6DF', '/storage/furniture/models/STG-003.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(40, 5, 'STG-004', 'Foyer Entryway Bench & Coat Rack', 'Multifunctional entry hall unit with a lower slatted shoe bench, cushioned seat, and 6 cast-iron coat hooks.', 260.00, 100.00, 180.00, 40.00, 70.00, 20.00, 'industrial', 'Reclaimed Pine & Black Iron Pipes', 'Dark Oak / Iron', '#3A2E28', '/storage/furniture/models/STG-004.glb', 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33');

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
(1, 1, '/storage/furniture/images/SOFA-001-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(2, 2, '/storage/furniture/images/SOFA-002-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(3, 3, '/storage/furniture/images/SOFA-003-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(4, 4, '/storage/furniture/images/SOFA-004-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(5, 5, '/storage/furniture/images/SOFA-005-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(6, 6, '/storage/furniture/images/SOFA-006-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(7, 7, '/storage/furniture/images/COFF-001-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(8, 8, '/storage/furniture/images/COFF-002-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(9, 9, '/storage/furniture/images/COFF-003-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(10, 10, '/storage/furniture/images/COFF-004-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(11, 11, '/storage/furniture/images/TV-001-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(12, 12, '/storage/furniture/images/TV-002-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(13, 13, '/storage/furniture/images/TV-003-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(14, 14, '/storage/furniture/images/TV-004-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(15, 15, '/storage/furniture/images/BED-001-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(16, 16, '/storage/furniture/images/BED-002-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(17, 17, '/storage/furniture/images/BED-003-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(18, 18, '/storage/furniture/images/BED-004-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(19, 19, '/storage/furniture/images/BED-005-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(20, 20, '/storage/furniture/images/NST-001-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(21, 21, '/storage/furniture/images/NST-002-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(22, 22, '/storage/furniture/images/NST-003-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(23, 23, '/storage/furniture/images/NST-004-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(24, 24, '/storage/furniture/images/DSK-001-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(25, 25, '/storage/furniture/images/DSK-002-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(26, 26, '/storage/furniture/images/DSK-003-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(27, 27, '/storage/furniture/images/DSK-004-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(28, 28, '/storage/furniture/images/DTB-001-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(29, 29, '/storage/furniture/images/DTB-002-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(30, 30, '/storage/furniture/images/DTB-003-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(31, 31, '/storage/furniture/images/DCH-001-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(32, 32, '/storage/furniture/images/DCH-002-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(33, 33, '/storage/furniture/images/DCH-003-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(34, 34, '/storage/furniture/images/DCH-004-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(35, 35, '/storage/furniture/images/DCH-005-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(36, 36, '/storage/furniture/images/DCH-006-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(37, 37, '/storage/furniture/images/STG-001-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(38, 38, '/storage/furniture/images/STG-002-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(39, 39, '/storage/furniture/images/STG-003-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(40, 40, '/storage/furniture/images/STG-004-primary.webp', 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(41, 1, '/storage/furniture/images/SOFA-001-front.webp', 0, 2, '2026-09-11 23:08:05', '2026-09-11 23:08:05'),
(42, 1, '/storage/furniture/images/SOFA-001-side.webp', 0, 3, '2026-09-11 23:08:05', '2026-09-11 23:08:05');

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
(1, 1, '/storage/furniture/models/SOFA-001.glb', 'glb', 3.24, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(2, 2, '/storage/furniture/models/SOFA-002.glb', 'glb', 2.58, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(3, 3, '/storage/furniture/models/SOFA-003.glb', 'glb', 3.20, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(4, 4, '/storage/furniture/models/SOFA-004.glb', 'glb', 3.03, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(5, 5, '/storage/furniture/models/SOFA-005.glb', 'glb', 2.61, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(6, 6, '/storage/furniture/models/SOFA-006.glb', 'glb', 2.75, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(7, 7, '/storage/furniture/models/COFF-001.glb', 'glb', 2.03, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(8, 8, '/storage/furniture/models/COFF-002.glb', 'glb', 1.65, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(9, 9, '/storage/furniture/models/COFF-003.glb', 'glb', 3.11, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(10, 10, '/storage/furniture/models/COFF-004.glb', 'glb', 1.92, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(11, 11, '/storage/furniture/models/TV-001.glb', 'glb', 1.61, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(12, 12, '/storage/furniture/models/TV-002.glb', 'glb', 2.31, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(13, 13, '/storage/furniture/models/TV-003.glb', 'glb', 2.69, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(14, 14, '/storage/furniture/models/TV-004.glb', 'glb', 3.46, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(15, 15, '/storage/furniture/models/BED-001.glb', 'glb', 2.80, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(16, 16, '/storage/furniture/models/BED-002.glb', 'glb', 1.82, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(17, 17, '/storage/furniture/models/BED-003.glb', 'glb', 2.52, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(18, 18, '/storage/furniture/models/BED-004.glb', 'glb', 3.39, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(19, 19, '/storage/furniture/models/BED-005.glb', 'glb', 2.57, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(20, 20, '/storage/furniture/models/NST-001.glb', 'glb', 2.96, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(21, 21, '/storage/furniture/models/NST-002.glb', 'glb', 2.78, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(22, 22, '/storage/furniture/models/NST-003.glb', 'glb', 3.32, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(23, 23, '/storage/furniture/models/NST-004.glb', 'glb', 2.83, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(24, 24, '/storage/furniture/models/DSK-001.glb', 'glb', 2.05, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(25, 25, '/storage/furniture/models/DSK-002.glb', 'glb', 2.67, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(26, 26, '/storage/furniture/models/DSK-003.glb', 'glb', 2.17, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(27, 27, '/storage/furniture/models/DSK-004.glb', 'glb', 1.50, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(28, 28, '/storage/furniture/models/DTB-001.glb', 'glb', 1.80, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(29, 29, '/storage/furniture/models/DTB-002.glb', 'glb', 1.78, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(30, 30, '/storage/furniture/models/DTB-003.glb', 'glb', 1.52, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(31, 31, '/storage/furniture/models/DCH-001.glb', 'glb', 1.94, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(32, 32, '/storage/furniture/models/DCH-002.glb', 'glb', 3.00, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(33, 33, '/storage/furniture/models/DCH-003.glb', 'glb', 2.14, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(34, 34, '/storage/furniture/models/DCH-004.glb', 'glb', 2.57, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(35, 35, '/storage/furniture/models/DCH-005.glb', 'glb', 1.63, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(36, 36, '/storage/furniture/models/DCH-006.glb', 'glb', 2.61, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(37, 37, '/storage/furniture/models/STG-001.glb', 'glb', 2.60, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(38, 38, '/storage/furniture/models/STG-002.glb', 'glb', 1.94, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(39, 39, '/storage/furniture/models/STG-003.glb', 'glb', 3.20, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(40, 40, '/storage/furniture/models/STG-004.glb', 'glb', 1.99, 1, 1, '2026-09-11 17:25:33', '2026-09-11 17:25:33');

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
(11, '2026_09_12_000011_create_favorites_table', 1);

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
(1, 'App\\Models\\User', 3, 'smartspace_auth', '1936a15cf477d3615bc938adc1cfe9183085f4133a8a9e8227afa833e57235ef', '[\"*\"]', '2026-09-11 17:32:40', NULL, '2026-09-11 17:32:40', '2026-09-11 17:32:40'),
(2, 'App\\Models\\User', 3, 'smartspace_auth', 'eacdf5f22a39a6c3bf14d08af3bb05e66a171908838c4cb22d34b3ace600c8e0', '[\"*\"]', NULL, NULL, '2026-09-11 17:32:40', '2026-09-11 17:32:40'),
(3, 'App\\Models\\User', 2, 'test_token', '69a7979745f28c0e35dfda94f87f664264474b2ad118d0c732f7f0e5fa9ee349', '[\"*\"]', '2026-09-11 17:32:41', NULL, '2026-09-11 17:32:41', '2026-09-11 17:32:41'),
(4, 'App\\Models\\User', 2, 'test_token_fav', 'e067154a64393d0d806014a117fd19752434afa1550fc844a55079b30f0f227e', '[\"*\"]', '2026-09-11 17:32:41', NULL, '2026-09-11 17:32:41', '2026-09-11 17:32:41'),
(5, 'App\\Models\\User', 4, 'smartspace_auth', 'dc2a0b9f246cf963decac3c5bfa51fc55f127b57843d72b1e78fb100ea70d343', '[\"*\"]', '2026-09-11 17:32:53', NULL, '2026-09-11 17:32:53', '2026-09-11 17:32:53'),
(6, 'App\\Models\\User', 4, 'smartspace_auth', '666f26b167a0d0561d867a73187e7383b8dd7e6f3fe1807807857756806a5876', '[\"*\"]', NULL, NULL, '2026-09-11 17:32:53', '2026-09-11 17:32:53'),
(7, 'App\\Models\\User', 2, 'test_token', '347361da4f84d0a52f4c768ba3a78245789ca9522c3e3bff3ca45f0a45159711', '[\"*\"]', '2026-09-11 17:32:53', NULL, '2026-09-11 17:32:53', '2026-09-11 17:32:53'),
(8, 'App\\Models\\User', 2, 'test_token_fav', 'a982e57b22932961be7357300833a1930cd3c66584988045ef361d9efd7a8ab1', '[\"*\"]', '2026-09-11 17:32:53', NULL, '2026-09-11 17:32:53', '2026-09-11 17:32:53'),
(9, 'App\\Models\\User', 5, 'smartspace_auth', '2684e88cb26e35aee730d273bfcad0c5bb0c9b64bc3c5bf259bb82040f2e8fc0', '[\"*\"]', '2026-09-11 17:33:22', NULL, '2026-09-11 17:33:22', '2026-09-11 17:33:22'),
(10, 'App\\Models\\User', 5, 'smartspace_auth', 'c85e89948bb5b0e14a1e549da12425799427d06719d859c06ccf4f05542c8aac', '[\"*\"]', NULL, NULL, '2026-09-11 17:33:22', '2026-09-11 17:33:22'),
(11, 'App\\Models\\User', 2, 'test_token', '4604b2b196359845540b34b3897d55d26683d17b35a9606361478b48d1451e91', '[\"*\"]', '2026-09-11 17:33:22', NULL, '2026-09-11 17:33:22', '2026-09-11 17:33:22'),
(12, 'App\\Models\\User', 2, 'test_token_fav', 'dece6346737c571d5b70449c5bf7dfd30a5046d68c724ac4cd966a8902fd869f', '[\"*\"]', '2026-09-11 17:33:22', NULL, '2026-09-11 17:33:22', '2026-09-11 17:33:22'),
(13, 'App\\Models\\User', 6, 'smartspace_auth', '5902baea2db2f992791e884ae5e38b97881ee601ec3b5d1d1af5925940550283', '[\"*\"]', '2026-09-11 18:11:38', NULL, '2026-09-11 18:11:38', '2026-09-11 18:11:38'),
(14, 'App\\Models\\User', 6, 'smartspace_auth', '227a596e639db9308ee05d5744a23ccf947bfefe7432cdbba567beb7bba95fe5', '[\"*\"]', NULL, NULL, '2026-09-11 18:11:38', '2026-09-11 18:11:38'),
(15, 'App\\Models\\User', 2, 'test_token', '1015930a7831467d3bf66cbe907eacbe6b26f1c95591d33b452788d081467087', '[\"*\"]', '2026-09-11 18:11:38', NULL, '2026-09-11 18:11:38', '2026-09-11 18:11:38'),
(16, 'App\\Models\\User', 2, 'test_token_fav', '8229f8fcfba141ece0287d49744bef9d9e5b937d6e1d0fa562338ae1b2a9a240', '[\"*\"]', '2026-09-11 18:11:38', NULL, '2026-09-11 18:11:38', '2026-09-11 18:11:38'),
(17, 'App\\Models\\User', 2, 'smartspace_auth', '55f1aaf89c5a0a14a3f928a02841d199940239e0e881ce8723d0d06cbc57c1a3', '[\"*\"]', NULL, NULL, '2026-09-11 19:39:31', '2026-09-11 19:39:31'),
(18, 'App\\Models\\User', 1, 'smartspace_auth', '1fff3a87fe5abcc250d73fc3e7e233853637b2934d32d74fd4b8c0778cdf244c', '[\"*\"]', NULL, NULL, '2026-09-11 19:39:36', '2026-09-11 19:39:36'),
(19, 'App\\Models\\User', 2, 'smartspace_auth', '9db901016ebf354f343dfb53c2f5cf5686f0dd369cab691e88b813b9c5aa5c65', '[\"*\"]', '2026-09-11 19:50:28', NULL, '2026-09-11 19:42:27', '2026-09-11 19:50:28'),
(22, 'App\\Models\\User', 7, 'smartspace_auth', '72949aae8257eea1b8b7b58f64ac2676f173be85c0a17be5b443218e44fe556f', '[\"*\"]', '2026-09-11 23:13:39', NULL, '2026-09-11 21:03:52', '2026-09-11 23:13:39');

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
(1, 'Administrator', 'admin', 'System administrator with full catalog and system management access.', '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(2, 'Customer', 'customer', 'Standard user who can design rooms, save projects, and favorite furniture.', '2026-09-11 17:25:33', '2026-09-11 17:25:33');

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
(1, 2, 'Nordic Living Room Concept', 'living_room', 420.00, 500.00, 260.00, 'scandinavian', NULL, 100.00, '{\"total_score\":100,\"is_valid\":true,\"verdict\":\"Excellent Fit\",\"badge\":\"\\ud83d\\udfe2\",\"description\":\"Optimal furniture arrangement with generous walking circulation and complete clearance compliance.\",\"room_dimensions\":{\"width_m\":4.2,\"length_m\":5,\"height_m\":2.6,\"area_sqm\":21},\"item_count\":4,\"breakdown\":{\"boundary_fit\":{\"score\":30,\"max\":30,\"status\":\"pass\",\"violation_count\":0,\"violations\":[]},\"collision\":{\"score\":25,\"max\":25,\"status\":\"pass\",\"collision_count\":0,\"collisions\":[]},\"clearance\":{\"score\":25,\"max\":25,\"status\":\"pass\",\"warning_count\":0,\"warnings\":[]},\"utilization\":{\"score\":10,\"max\":10,\"walking_ratio\":0.8049,\"occupied_percentage\":19.5,\"room_area_sqm\":21,\"furniture_area_sqm\":4.1,\"status\":\"excellent\"},\"room_fitness\":{\"score\":10,\"max\":10,\"matched_items\":4,\"total_items\":4,\"status\":\"pass\",\"unmatched\":[]}},\"evaluation_notes\":\"All items safely contained within room perimeter. Zero collision overlaps. Full front and side clearance corridors maintained. Space utilization: 19.5% occupied (excellent circulation).\"}', '2026-09-11 17:25:33', '2026-09-11 17:25:37'),
(6, 7, 'Nordik Living Room', 'living_room', 450.00, 500.00, 280.00, 'scandinavian', NULL, 100.00, '{\"total_score\":100,\"is_valid\":true,\"verdict\":\"Excellent Fit\",\"badge\":\"\\ud83d\\udfe2\",\"description\":\"Optimal furniture arrangement with generous walking circulation and complete clearance compliance.\",\"room_dimensions\":{\"width_m\":4.5,\"length_m\":5,\"height_m\":2.8,\"area_sqm\":22.5},\"item_count\":7,\"breakdown\":{\"boundary_fit\":{\"score\":30,\"max\":30,\"status\":\"pass\",\"violation_count\":0,\"violations\":[]},\"collision\":{\"score\":25,\"max\":25,\"status\":\"pass\",\"collision_count\":0,\"collisions\":[]},\"clearance\":{\"score\":25,\"max\":25,\"status\":\"pass\",\"warning_count\":0,\"warnings\":[]},\"utilization\":{\"score\":10,\"max\":10,\"walking_ratio\":0.8406,\"occupied_percentage\":15.9,\"room_area_sqm\":22.5,\"furniture_area_sqm\":3.59,\"status\":\"excellent\"},\"room_fitness\":{\"score\":10,\"max\":10,\"matched_items\":7,\"total_items\":7,\"status\":\"pass\",\"unmatched\":[]}},\"evaluation_notes\":\"All items safely contained within room perimeter. Zero collision overlaps. Full front and side clearance corridors maintained. Space utilization: 15.9% occupied (excellent circulation).\"}', '2026-09-11 21:06:03', '2026-09-11 21:58:06'),
(7, 7, 'AI-Assisted Living Space', 'living_room', 420.00, 500.00, 280.00, 'scandinavian', NULL, 100.00, '{\"total_score\":100,\"is_valid\":true,\"verdict\":\"Excellent Fit\",\"badge\":\"\\ud83d\\udfe2\",\"description\":\"Optimal furniture arrangement with generous walking circulation and complete clearance compliance.\",\"room_dimensions\":{\"width_m\":4.2,\"length_m\":5,\"height_m\":2.8,\"area_sqm\":21},\"item_count\":0,\"breakdown\":{\"boundary_fit\":{\"score\":30,\"max\":30,\"status\":\"pass\",\"violation_count\":0,\"violations\":[]},\"collision\":{\"score\":25,\"max\":25,\"status\":\"pass\",\"collision_count\":0,\"collisions\":[]},\"clearance\":{\"score\":25,\"max\":25,\"status\":\"pass\",\"warning_count\":0,\"warnings\":[]},\"utilization\":{\"score\":10,\"max\":10,\"walking_ratio\":1,\"occupied_percentage\":0,\"room_area_sqm\":21,\"furniture_area_sqm\":0,\"status\":\"excellent\"},\"room_fitness\":{\"score\":10,\"max\":10,\"matched_items\":0,\"total_items\":0,\"status\":\"pass\"}},\"evaluation_notes\":\"All items safely contained within room perimeter. Zero collision overlaps. Full front and side clearance corridors maintained. Space utilization: 0% occupied (excellent circulation).\"}', '2026-09-11 21:16:38', '2026-09-11 21:16:38');

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
(1, 1, 1, 0.0000, 0.0000, -1.2000, 0.0000, 1.000, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(2, 1, 7, 0.0000, 0.0000, 0.2000, 0.0000, 1.000, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(3, 1, 12, 0.0000, 0.0000, 1.8000, 180.0000, 1.000, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(4, 1, 39, -1.5000, 0.0000, 0.4000, 60.0000, 1.000, '2026-09-11 17:25:33', '2026-09-11 17:25:33'),
(25, 6, 40, -1.7470, 0.0000, -2.2060, 0.0000, 1.000, '2026-09-11 21:58:06', '2026-09-11 21:58:06'),
(26, 6, 39, 1.7780, 0.0000, -1.8800, 0.0000, 1.000, '2026-09-11 21:58:06', '2026-09-11 21:58:06'),
(27, 6, 40, 0.0000, 0.0000, 0.0000, 0.0000, 1.000, '2026-09-11 21:58:06', '2026-09-11 21:58:06'),
(28, 6, 39, 1.4030, 0.0000, 0.7990, 0.0000, 1.000, '2026-09-11 21:58:06', '2026-09-11 21:58:06'),
(29, 6, 39, 0.8500, 0.0000, -0.9060, 0.0000, 1.000, '2026-09-11 21:58:06', '2026-09-11 21:58:06'),
(30, 6, 38, -0.6000, 0.0000, -0.6000, 0.0000, 1.000, '2026-09-11 21:58:06', '2026-09-11 21:58:06'),
(31, 6, 38, 0.1010, 0.0000, -2.1140, 0.0000, 1.000, '2026-09-11 21:58:06', '2026-09-11 21:58:06');

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
(1, 1, 'SmartSpace Admin', 'admin@smartspace.local', '2026-09-11 17:25:33', '$2y$12$HT1L78kxPwhhd7pbFt32FOfqQUOAy3.YNr7itIxZU90b9Y1KZRDkq', NULL, NULL, '2026-09-11 17:25:33', '2026-09-11 19:39:07'),
(2, 2, 'Demo Customer', 'customer@smartspace.local', '2026-09-11 17:25:33', '$2y$12$ayjwLxKVRq3r4m2n/PoGNeqRugCjGvHki2iir55saqDvlaCM6Pu7O', NULL, NULL, '2026-09-11 17:25:33', '2026-09-11 19:39:07'),
(3, 2, 'Test Spatial Architect', 'architect_6aa4abb8b4c48@smartspace.local', NULL, '$2y$04$asPIMK8NQqmELUPy4cUj0Oa2JARNeFqLwdXTg2qTpD9k7D/mzYXNm', NULL, NULL, '2026-09-11 17:32:40', '2026-09-11 17:32:40'),
(4, 2, 'Test Spatial Architect', 'architect_6aa4abc556608@smartspace.local', NULL, '$2y$04$MRXJ5IZKxm/JcIX5uREnRepRQLRgt/odS0H26GRB0Sa.VUknWOKLK', NULL, NULL, '2026-09-11 17:32:53', '2026-09-11 17:32:53'),
(5, 2, 'Test Spatial Architect', 'architect_6aa4abe21742c@smartspace.local', NULL, '$2y$04$pU7djT0TAOSzjVzCntyQY.FB5jD5Lpg6QS9F7Lx09B9Af4GPOogHy', NULL, NULL, '2026-09-11 17:33:22', '2026-09-11 17:33:22'),
(6, 2, 'Test Spatial Architect', 'architect_6aa4b4d9e2542@smartspace.local', NULL, '$2y$04$U3d9MT6ZT9oO8X60FqEAOujas3Fr2UXrMat/YZKvtvQiyEIcSPu2.', NULL, NULL, '2026-09-11 18:11:38', '2026-09-11 18:11:38'),
(7, 2, 'Alex Rivera', 'alex@example.com', NULL, '$2y$12$xBLwipteyESEu2t4XSlNme/BUXUBWE.BshsIAFXTvth2k3AsImEUa', NULL, NULL, '2026-09-11 21:03:52', '2026-09-11 21:03:52');

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `furniture`
--
ALTER TABLE `furniture`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `furniture_images`
--
ALTER TABLE `furniture_images`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `furniture_models`
--
ALTER TABLE `furniture_models`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `room_analyses`
--
ALTER TABLE `room_analyses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `room_projects`
--
ALTER TABLE `room_projects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `room_project_furniture`
--
ALTER TABLE `room_project_furniture`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
