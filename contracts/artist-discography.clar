;; Artist discography
;; contract that models and artist discography (discography => albums =>tracks)
;; written by Setzeus / Daniel

;; Discography
;; An arstist discography is a list of albums
;; The artist or an admin can start a discography & can add and remove albums.

;; Album
;; An album is a list of tracks + some additonal info (such as when it was published)
;; The artist or admin can start an album & can add/remove tracks.

;; Track
;; A track is made up of a name, a duration (in seconds) and a possible feature (optional feature)
;; An artist or an admin  can start a track & can add/remove tracks

;;;;;;;;;;;;;;;;;;;;;;;; 
;; consts, vars & maps;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Admin list of principals
(define-data-var admins (list 10 principal) (list tx-sender))

;; map that keeps tracks of a single track
(define-map track { artist:principal, album-id: uint, track-id: uint } { 
  title: (string-ascii 24),
  duration: uint,
  featured: (optional principal)
})

;; map that keeps tracks of an album
(define-map album { artist: principal, album-id: uint } { 
    title: (string-ascii 24),
    tracks: (list 20 uint),
    height-published: uint
})

;; map that keeps tracks of a discography
(define-map discography principal (list 10 uint))



;;;;;;;;;;;;;;;;;;
;;Read functions;;
;;;;;;;;;;;;;;;;;;

;; get track data
(define-read-only (get-track-data (artist principal) (album-id uint) (track-id uint)) 
  (map-get? track { artist: artist, album-id: album-id, track-id: track-id})
)

;; get featured artist
(define-read-only (get-featured-artist (track-id uint) (artist principal) (album-id uint)) 
  (get featured (map-get? track { artist: artist, album-id: album-id, track-id: track-id }))
)

;; get album data
(define-read-only (get-album-data (album-id uint) (artist principal)) 
  (map-get? album { artist: artist, album-id: album-id })
)

;; get published
(define-read-only (get-album-published-height (album-id uint) (artist principal)) 
  (get height-published (map-get? album { artist: artist, album-id: album-id }))
)

;; get discography
(define-read-only (get-discography (artist principal)) 
  (map-get? discography artist)
)


;;;;;;;;;;;;;;;;;;; 
;;write functions;;
;;;;;;;;;;;;;;;;;;;

;; Add a track
;; @desc - function that allows a user or admin to add a track
;; @param - title (string-ascii 24), duration (uint), featured-artist (optional principal), album-id (uint)
(define-public (add-a-track (artist principal) (title (string-ascii 24)) (duration uint) (featured-artist (optional principal)) (album-id uint)) 
  (let
    (
      (current-discography (default-to (list ) (map-get? discography artist)))
      (current-album (unwrap! (index-of? current-discography album-id) (err u2)))
      (current-album-data (unwrap! (map-get? album {artist: artist,album-id: album-id }) (err u2)))
      (current-album-tracks (get tracks current-album-data))
      (current-album-track-id (len current-album-tracks))
      (next-album-track-id (+ current-album-track-id))
    )
    ;; Asserts that tx-sender is either artist or admin
    (asserts! (or (is-eq tx-sender artist) (is-some (index-of (var-get admins) tx-sender) )) (err u1))

    ;; Asserts duration is less than 600 (10min)
    (asserts! (< duration u600) (err u3))

    ;; Map-set new track
    (map-set track {artist: artist, album-id: album-id, track-id: next-album-track-id } {
      title: title,
      duration: duration,
      featured: featured-artist
    })

    ;; Map-set append track to album
    (ok (map-set album { artist: artist, album-id: album-id }
        (merge 
          current-album-data
          {tracks: (unwrap! (as-max-len? (append current-album-tracks next-album-track-id) u20) (err u4))}
        )
      )
    )
  ) 
)

;; add an album
;; @desc - function that allows the artist or admin to add a new album, or start a new discography & then an album.
(define-public (add-album-or-create-discography-and-add-album (artist principal) (album-title (string-ascii 24))) 
  (let
    (
      (current-discography (default-to (list ) (map-get? discography artist)))
      (current-album-id (len current-discography))
      (next-album-id (+ u1 current-album-id))
    )

    ;; Check whether discography exist / if discography is-some
    (ok (if (is-eq current-album-id)

        ;; Empty discography
        (begin 
          (map-set discography artist (list current-album-id))
          (map-set album {artist: artist, album-id: current-album-id} {
            title: album-title,
            tracks: (list ),
            height-published: block-height
          })
        )
        
        ;; Discography exists
        (begin 
          (map-set discography artist (unwrap! (as-max-len? (append current-discography next-album-id) u10) (err u4)))
          (map-set album {artist: artist, album-id: next-album-id} {
            title: album-title,
            tracks: (list ),
            height-published: block-height
          })
        )
      )
    )
  )
)

;;;;;;;;;;;;;;;;;;; 
;;Admin Functions;;
;;;;;;;;;;;;;;;;;;;

;; Add admin
;; @desc - Function that an existing admin can call to add a new admin
;; @param - new-admin (principal)

;; Add admin
;; @desc - function to add an admin to existing admin-list
;; @param - new-admin: principal
(define-public (add-admin (new-admin principal)) 
  (let
    (
      (current-admins (var-get admins))
    ) 
      ;; Assert tx-sender is a current admin 
      (asserts! (is-some (index-of? current-admins tx-sender)) (err "err-not-authorised"))

      ;; Assert that new-admin does not exist in list of admins
      (asserts! (is-some (index-of? current-admins new-admin)) (err "err-duplicate-admins"))

      ;; Append new-admin to the admin list
      (ok (var-set admins 
        (unwrap! (as-max-len? (append current-admins new-admin) u10) (err "err-admin-list-overflow")
        ))
      )
  )
)