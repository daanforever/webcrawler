
CREATE TABLE `url` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(64) COLLATE utf8_bin NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_url` (`url`) USING HASH,
  KEY `index_updated` (`updated`) USING BTREE
) ENGINE=MyISAM AUTO_INCREMENT=12062 DEFAULT CHARSET=utf8 COLLATE=utf8_bin
