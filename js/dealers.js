/* Triple R Trailers dealer locations.
   Names, towns, and phone numbers checked against the official Triple R
   dealer sheet from the office, August 2026. Coordinates are city-level,
   close enough to route a buyer to the right town.
   To pin a dealer, fill in city, state, phone, lat, lng.
   Dealers without lat/lng stay in the site directory but are not pinned. */
window.TRIPLE_R_DEALERS = [
  { name: "Triple R Trailers (Factory)", city: "Booneville", state: "MS", phone: "(662) 728-7975", lat: 34.6579, lng: -88.5667, factory: true },

  /* Mississippi */
  { name: "Murphy Bros", city: "Booneville", state: "MS", phone: "(662) 720-6353", lat: 34.672, lng: -88.552 },
  { name: "CDF Customs LLC", city: "Booneville", state: "MS", phone: "(662) 416-0693", lat: 34.645, lng: -88.585 },
  { name: "Sid's Trading Co", city: "Iuka", state: "MS", phone: "(662) 424-0025", lat: 34.81, lng: -88.19 },
  { name: "L & S Golf Carts", city: "Iuka", state: "MS", phone: "(662) 424-0200", lat: 34.822, lng: -88.205 },
  { name: "Main Street Cycle", city: "Tishomingo", state: "MS", phone: "(662) 438-6407", lat: 34.63, lng: -88.23 },
  { name: "Wood Sales, Inc.", city: "Golden", state: "MS", phone: "(662) 454-9237", lat: 34.48, lng: -88.19 },
  { name: "Ferrell's Home & Outdoor", city: "Corinth", state: "MS", phone: "(662) 287-2165", lat: 34.93, lng: -88.52 },
  { name: "Trailer Sales (Maris)", city: "Corinth", state: "MS", phone: "", lat: 34.945, lng: -88.505 },
  { name: "Jason Dietsch Trailer Sales Midsouth", city: "Michigan City", state: "MS", phone: "(662) 224-0007", lat: 34.99, lng: -89.25 },
  { name: "Chickasaw Equipment Co.", city: "Tupelo", state: "MS", phone: "(662) 842-2232", lat: 34.26, lng: -88.70 },
  { name: "Service Supply Co", city: "Pontotoc", state: "MS", phone: "(662) 509-0553", lat: 34.26, lng: -89.01 },
  { name: "David's Used Cars", city: "Houlka", state: "MS", phone: "(662) 568-2553", lat: 34.03, lng: -89.02 },
  { name: "Show-N-Go LLC", city: "Houlka", state: "MS", phone: "", lat: 34.045, lng: -89.035 },
  { name: "Saunders Equipment", city: "Senatobia", state: "MS", phone: "", lat: 34.62, lng: -89.97 },
  { name: "True Grit Trading Co", city: "Starkville", state: "MS", phone: "(662) 574-4225", lat: 33.45, lng: -88.82 },
  { name: "H & R Agri-Power", city: "Columbus", state: "MS", phone: "(662) 328-5341", lat: 33.50, lng: -88.43 },
  { name: "M & S Sales, Inc.", city: "Greenwood", state: "MS", phone: "(662) 453-6111", lat: 33.52, lng: -90.18 },
  { name: "Webb Machine & Supply", city: "Webb", state: "MS", phone: "(662) 375-8627", lat: 33.95, lng: -90.34 },
  { name: "MC Trailer Sales", city: "Brandon", state: "MS", phone: "(601) 405-5553", lat: 32.28, lng: -90.01 },
  { name: "Patriot Motorsports LLC", city: "Vicksburg", state: "MS", phone: "(601) 636-3461", lat: 32.35, lng: -90.88 },
  { name: "Beem Pawn & Gun", city: "Philadelphia", state: "MS", phone: "(601) 656-0038", lat: 32.77, lng: -89.12 },
  { name: "Smith's Enterprises", city: "Brookhaven", state: "MS", phone: "(601) 823-1222", lat: 31.58, lng: -90.44 },
  { name: "TBJ Trailers & Portable Bldgs LLC", city: "Tylertown", state: "MS", phone: "(601) 876-1837", lat: 31.12, lng: -90.14 },
  { name: "VIC, LLC dba Stringers", city: "Picayune", state: "MS", phone: "(601) 798-7131", lat: 30.545, lng: -89.66 },
  { name: "Uncle Sam's Tire & Auto LLP", city: "Southaven", state: "MS", phone: "(662) 510-5120", lat: 34.99, lng: -90.00 },

  /* Tennessee */
  { name: "Vista Trailers LLC", city: "Oakland", state: "TN", phone: "(901) 490-8205", lat: 35.23, lng: -89.51 },
  { name: "Tom Miller Motorsports", city: "Huntingdon", state: "TN", phone: "(731) 986-0893", lat: 36.00, lng: -88.43 },
  { name: "Freedom Outdoors Inc", city: "Parsons", state: "TN", phone: "(731) 847-2007", lat: 35.65, lng: -88.13 },
  { name: "Pleasants Gro & Gen Merchandise", city: "Moscow", state: "TN", phone: "(901) 877-7932", lat: 35.06, lng: -89.40 },

  /* Alabama */
  { name: "Ally Automotive", city: "Florence", state: "AL", phone: "(256) 702-3514", lat: 34.80, lng: -87.68 },
  { name: "Longrider Supply Co", city: "Florence", state: "AL", phone: "(256) 767-6068", lat: 34.815, lng: -87.665 },
  { name: "Shoals Outdoor Sports", city: "Tuscumbia", state: "AL", phone: "(256) 389-8150", lat: 34.73, lng: -87.70 },
  { name: "Rival Feed & Seed LLC", city: "Florence", state: "AL", phone: "(256) 627-8985", lat: 34.79, lng: -87.655 },
  { name: "Johnny's 4 Wheelers", city: "Red Bay", state: "AL", phone: "(256) 810-0106", lat: 34.44, lng: -88.14 },
  { name: "Oak Ridge Rentals LLC", city: "Hartselle", state: "AL", phone: "(256) 789-5258", lat: 34.44, lng: -86.94 },
  { name: "Royal Trailer Sales", city: "Anniston", state: "AL", phone: "(205) 753-3337", lat: 33.66, lng: -85.83 },

  /* Arkansas */
  { name: "Grady's", city: "Ward", state: "AR", phone: "(501) 425-8637", lat: 35.03, lng: -91.95 },

  /* Missouri */
  { name: "Midsouth Trailers, LLC", city: "Barnhart", state: "MO", phone: "(636) 428-4082", lat: 38.34, lng: -90.40 },
  { name: "Newline Trailers", city: "Troy", state: "MO", phone: "(636) 525-5555", lat: 38.98, lng: -90.97 },
  { name: "Top Dawg Trailer Sales LLC", city: "West Plains", state: "MO", phone: "", lat: 36.73, lng: -91.85 },

  /* Louisiana */
  { name: "Pearson's Trailer Parts & Repair Co", city: "Kenner", state: "LA", phone: "(504) 469-6372", lat: 29.99, lng: -90.24 },
  { name: "RCI (Rotolo Consultants Inc)", city: "Slidell", state: "LA", phone: "(601) 842-7130", lat: 30.28, lng: -89.78 },

  /* Beyond the Mid-South */
  { name: "Hometown Buildings Plus", city: "Russellville", state: "KY", phone: "(270) 221-2380", lat: 36.85, lng: -86.89 },
  { name: "CBM Trailer Sales", city: "Hopkinsville", state: "KY", phone: "", lat: 36.87, lng: -87.49 },
  { name: "Jason Dietsch Sales LLC", city: "Edgerton", state: "OH", phone: "(419) 298-0777", lat: 41.45, lng: -84.75 },
  { name: "KDZ Motorsports", city: "Auburn", state: "IN", phone: "(260) 927-0533", lat: 41.37, lng: -85.06 },
  { name: "Pfeiffer Sales", city: "Bristol", state: "WI", phone: "(262) 843-1373", lat: 42.55, lng: -88.04 },
  { name: "One Stop Trailer Shop LLC", city: "Barrington", state: "NH", phone: "", lat: 43.2223, lng: -71.047 },

  /* Locations being confirmed with the office */
  { name: "American Trailers & Storage", city: "", state: "", phone: "", lat: null, lng: null },
  { name: "Andrew", city: "", state: "", phone: "", lat: null, lng: null },
  { name: "Circle S Transport LLC", city: "", state: "", phone: "", lat: null, lng: null },
  { name: "Citadel Storage LLC", city: "", state: "", phone: "", lat: null, lng: null },
  { name: "DeWitt Tool & Equipment", city: "", state: "", phone: "", lat: null, lng: null },
  { name: "Hoss Trailer Sales", city: "", state: "", phone: "", lat: null, lng: null },
  { name: "The Storage Place", city: "", state: "", phone: "", lat: null, lng: null },
  { name: "Timberline Trailers LLC", city: "", state: "", phone: "", lat: null, lng: null },
  { name: "Waldon Trailers", city: "", state: "", phone: "", lat: null, lng: null },
];
