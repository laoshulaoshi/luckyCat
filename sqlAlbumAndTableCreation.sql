#Command: mysql -u mydbusername -p musicDB < sqlAlbumAndTableCreation.sql

DROP TABLE IF EXISTS tracks;
DROP TABLE IF EXISTS albums;

CREATE TABLE albums
(
albumRFID VARCHAR(255) PRIMARY KEY, 
albumName VARCHAR(255),
currentTrackIndex INT,
currentTrackOffsetSecs INT
) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

CREATE TABLE tracks 
(
trackID INT AUTO_INCREMENT PRIMARY KEY,
albumRFID VARCHAR(255) NOT NULL REFERENCES albums(albumRFID),
trackNum INT NOT NULL,
trackName VARCHAR(255) NOT NULL,
fileName VARCHAR(255) NOT NULL
) DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;






INSERT INTO albums (albumRFID, albumName) VALUES ("2451098201", "Robin Hood");
INSERT INTO albums (albumRFID, albumName) VALUES ("1811198201", "Aesop\'s Fables");



INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("1811198201", 1, "Androcles and the Lion", "fablesAndroclesAndTheLion.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("1811198201", 2, "The Hare and the Tortoise", "fablesTheHareAndTheTortoise.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("1811198201", 3, "The Boy Who Cried Wolf", "fablesTheBoyWhoCriedWolf.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("1811198201", 4, "The Oak and the Reed", "fablesTheOakAndTheReed.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("1811198201", 5, "Juno and the Peacock", "fablesJunoAndThePeacock.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("1811198201", 6, "The Donkey and the Lion", "fablesTheDonkeyAndTheLion.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("1811198201", 7, "The Rat and the Elephant", "fablesTheRatAndTheElephant.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("1811198201", 8, "Town Mouse, Country Mouse", "fablesTownMouseCountryMouse.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("1811198201", 9, "Two Frogs and the Well", "fablesTwoFrogsAndTheWell.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("1811198201", 10, "How the Elephant Got Its Trunk", "fablesHowTheElephantGotItsTrunk.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("1811198201", 11, "The Wind and the Sun", "fablesTheWindAndTheSun.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("1811198201", 12, "The Milkmaid", "fablesTheMilkmaid.ogg");



INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("2451098201", 1, "The Guest of Robin Hood", "robinhoodTheGuestOfRobinHood.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("2451098201", 2, "The Sheriff Who Came to Dinner With Robin Hood", "robinhoodTheSheriffWhoCameToDinnerWithRobinHood.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("2451098201", 3, "Robin Hood and Maid Marian", "robinhoodRobinHoodAndMaidMarian.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("2451098201", 4, "The Golden Arrow", "robinhoodTheGoldenArrow.ogg");
INSERT INTO tracks(albumRFID, trackNum, trackName, fileName) VALUES ("2451098201", 5, "How King Richard Met Robin Hood", "robinhoodHowKingRichardMetRobinHood.ogg");





