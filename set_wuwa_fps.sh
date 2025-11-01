#!/bin/bash
# Requires: sqlite3

set -e

#MAKE SURE YOUR GAME PATH IS CORRECT
GAME_PATH="/home/$USER/.local/share/Steam/steamapps/common/Wuthering Waves"

DB_PATH="$GAME_PATH/Client/Saved/LocalStorage/LocalStorage.db"
CONFIG_PATH="$GAME_PATH/Client/Saved/Config/WindowsNoEditor/GameUserSettings.ini"
FPS=120

if [[ ! -d "$GAME_PATH" ]]; then
    echo "Error: Game directory not found at $GAME_PATH"
    exit 1
fi

if [[ ! -f "$DB_PATH" ]]; then
    echo "Error: LocalStorage.db not found at $DB_PATH"
    exit 1
fi

if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "Error: GameUserSettings.ini not found at $CONFIG_PATH"
    exit 1
fi

## --- Apply settings to sqlite database ---
sqlite3 "$DB_PATH" <<SQL

-- Drop existing trigger
DROP TRIGGER IF EXISTS prevent_custom_frame_rate_update;

-- Recreate trigger to lock FPS
CREATE TRIGGER prevent_custom_frame_rate_update
AFTER UPDATE OF value ON LocalStorage
WHEN NEW.key = 'CustomFrameRate'
BEGIN
    UPDATE LocalStorage
    SET value = $FPS
    WHERE key = 'CustomFrameRate';
END;

-- Set FPS
UPDATE LocalStorage SET value = '$FPS' WHERE key = 'CustomFrameRate';

-- Clean up old menu data
DELETE FROM LocalStorage WHERE key IN ('MenuData', 'PlayMenuInfo');

INSERT INTO LocalStorage (key, value) VALUES ('MenuData', '{"___MetaType___":"___Map___","Content":[[1,100],[2,100],[3,100],[4,100],[5,0],[6,0],[7,-0.4658685302734375],[10,3],[11,3],[20,0],[21,0],[22,0],[23,0],[24,0],[25,0],[26,0],[27,0],[28,0],[29,0],[30,0],[31,0],[32,0],[33,0],[34,0],[35,0],[36,0],[37,0],[38,0],[39,0],[40,0],[41,0],[42,0],[43,0],[44,0],[45,0],[46,0],[47,0],[48,0],[49,0],[50,0],[51,1],[52,1],[53,0],[54,3],[55,1],[56,2],[57,1],[58,1],[59,1],[61,0],[62,0],[63,1],[64,1],[65,0],[66,0],[67,3],[68,2],[69,100],[70,100],[79,1],[81,0],[82,1],[83,1],[84,0],[85,0],[87,0],[88,0],[89,50],[90,50],[91,50],[92,50],[93,1],[99,0],[100,30],[101,0],[102,1],[103,0],[104,50],[105,0],[106,0.3],[107,0],[112,0],[113,0],[114,0],[115,0],[116,0],[117,0],[118,0],[119,0],[120,0],[121,1],[122,1],[123,0],[130,0],[131,0],[132,1],[135,1],[133,0]]}');
INSERT INTO LocalStorage (key, value) VALUES ('PlayMenuInfo', '{"1":100,"2":100,"3":100,"4":100,"5":0,"6":0,"7":-0.4658685302734375,"10":3,"11":3,"20":0,"21":0,"22":0,"23":0,"24":0,"25":0,"26":0,"27":0,"28":0,"29":0,"30":0,"31":0,"32":0,"33":0,"34":0,"35":0,"36":0,"37":0,"38":0,"39":0,"40":0,"41":0,"42":0,"43":0,"44":0,"45":0,"46":0,"47":0,"48":0,"49":0,"50":0,"51":1,"52":1,"53":0,"54":3,"55":1,"56":2,"57":1,"58":1,"59":1,"61":0,"62":0,"63":1,"64":1,"65":0,"66":0,"67":3,"68":2,"69":100,"70":100,"79":1,"81":0,"82":1,"83":1,"84":0,"85":0,"87":0,"88":0,"89":50,"90":50,"91":50,"92":50,"93":1,"99":0,"100":30,"101":0,"102":1,"103":0,"104":50,"105":0,"106":0.3,"107":0,"112":0,"113":0,"114":0,"115":0,"116":0,"117":0,"118":0,"119":0,"120":0,"121":1,"122":1,"123":0,"130":0,"131":0,"132":1}');
SQL

echo "Database LocalStorage.db updated"

#Replace FrameRateLimit value to 120fps
sed -i -e 's/^FrameRateLimit=.*/FrameRateLimit=120/' "$CONFIG_PATH"
echo "Config GameUserSettings.ini updated"

echo "Done!"
