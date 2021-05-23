/* GCompris
 *
 * SPDX-FileCopyrightText: 2015 Bruno Coudoin <bruno.coudoin@gcompris.net>
 *
 * Authors:
 *   Bruno Coudoin <bruno.coudoin@gcompris.net> (GTK+ version)
 *   Pulkit Gupta <pulkitgenius@gmail.com> (Qt Quick port)
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.9

QtObject {
   property string instruction: qsTr("Transportation")
   property var levels: [
      {
          "pixmapfile": "images/helico_cornu.svg",
          "x": 0.75,
          "y": 0.2,
          "width": 0.4,
          "height": 0.2
      },
      {
          "pixmapfile": "images/Eole.svg",
          "x": "0.5",
          "y": "0.65",
          "width": 0.4,
          "height": 0.2
      },
      {
          "pixmapfile": "images/mongolfiere.svg",
          "x": 0.25,
          "y": 0.2,
          "width": 0.4,
          "height": 0.2
      },
      {
		  "text": qsTr("1783 Montgolfier brothers' hot air balloon"),
		  "x": "0.25",
		  "y": 0.4,
		  "width": "0.4",
          "height": 0.15,
		  "type": "DisplayText"
      },
      {
		  "text": qsTr("1880 Clement Ader's Eole"),
		  "x": "0.5",
		  "y": 0.85,
		  "width": "0.4",
          "height": 0.15,
		  "type": "DisplayText"
      },
      {
		  "text": qsTr("1906 Paul Cornu First helicopter flight"),
          "x": 0.75,
		  "y": 0.4,
          "width": 0.4,
          "height": 0.15,
		  "type": "DisplayText"
      }
   ]
}
