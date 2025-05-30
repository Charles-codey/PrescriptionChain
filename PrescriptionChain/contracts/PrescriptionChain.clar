;; PrescriptionChain - Secure prescription tracking and verification
;; Version: 1.0.0

;; Data structures
(define-map prescriptions
  { prescription-id: (string-ascii 64) }
  { 
    patient-id: (string-ascii 64),
    doctor-id: principal,
    medication: (string-ascii 64),
    dosage: (string-ascii 32),
    issue-date: uint,
    expiry-date: uint,
    filled: bool,
    fill-date: (optional uint)
  })

(define-map authorized-doctors { doctor: principal } bool)
(define-map authorized-pharmacies { pharmacy: principal } bool)

(define-data-var admin principal tx-sender)

;; Add an authorized doctor
(define-public (add-doctor (doctor-principal principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set authorized-doctors { doctor: doctor-principal } true))))

;; Add an authorized pharmacy
(define-public (add-pharmacy (pharmacy-principal principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set authorized-pharmacies { pharmacy: pharmacy-principal } true))))

;; Issue a new prescription (only by authorized doctors)
(define-public (issue-prescription
  (prescription-id (string-ascii 64))
  (patient-id (string-ascii 64))
  (medication (string-ascii 64))
  (dosage (string-ascii 32))
  (expiry-date uint))
  (begin
    (asserts! (default-to false (map-get? authorized-doctors { doctor: tx-sender })) (err u403))
    (asserts! (is-none (map-get? prescriptions { prescription-id: prescription-id })) (err u409))
    (ok (map-set prescriptions
      { prescription-id: prescription-id }
      { 
        patient-id: patient-id,
        doctor-id: tx-sender,
        medication: medication,
        dosage: dosage,
        issue-date: stacks-block-height,
        expiry-date: expiry-date,
        filled: false,
        fill-date: none
      }))))

;; Fill a prescription (only by authorized pharmacies)
(define-public (fill-prescription (prescription-id (string-ascii 64)))
  (let ((prescription (map-get? prescriptions { prescription-id: prescription-id })))
    (begin
      (asserts! (default-to false (map-get? authorized-pharmacies { pharmacy: tx-sender })) (err u403))
      (asserts! (is-some prescription) (err u404))
      (asserts! (not (get filled (unwrap-panic prescription))) (err u400))
      (asserts! (< stacks-block-height (get expiry-date (unwrap-panic prescription))) (err u400))
      (ok (map-set prescriptions
        { prescription-id: prescription-id }
        (merge (unwrap-panic prescription) { filled: true, fill-date: (some stacks-block-height) }))))))

;; Verify a prescription
(define-read-only (verify-prescription (prescription-id (string-ascii 64)))
  (let ((prescription (map-get? prescriptions { prescription-id: prescription-id })))
    (if (is-some prescription)
      (ok (unwrap-panic prescription))
      (err u404))))

;; Check if a prescription is valid and unfilled
(define-read-only (is-valid-unfilled (prescription-id (string-ascii 64)))
  (let ((prescription (map-get? prescriptions { prescription-id: prescription-id })))
    (if (is-some prescription)
      (let ((rx (unwrap-panic prescription)))
        (and (not (get filled rx)) (< stacks-block-height (get expiry-date rx))))
      false)))

;; Get prescription details (read-only function for authorized access)
(define-read-only (get-prescription (prescription-id (string-ascii 64)))
  (map-get? prescriptions { prescription-id: prescription-id }))

;; Check if doctor is authorized
(define-read-only (is-authorized-doctor (doctor principal))
  (default-to false (map-get? authorized-doctors { doctor: doctor })))

;; Check if pharmacy is authorized
(define-read-only (is-authorized-pharmacy (pharmacy principal))
  (default-to false (map-get? authorized-pharmacies { pharmacy: pharmacy })))

;; Remove doctor authorization (admin only)
(define-public (remove-doctor (doctor-principal principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-delete authorized-doctors { doctor: doctor-principal }))))

;; Remove pharmacy authorization (admin only)
(define-public (remove-pharmacy (pharmacy-principal principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-delete authorized-pharmacies { pharmacy: pharmacy-principal }))))

;; Transfer admin role (current admin only)
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))))
    