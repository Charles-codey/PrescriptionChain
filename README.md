# PrescriptionChain

A blockchain-based prescription management system built on the Stacks blockchain.

## Overview

PrescriptionChain provides a secure and transparent way to manage medical prescriptions, preventing fraud and ensuring that medications are dispensed appropriately. The system connects doctors, patients, and pharmacies in a trustless environment.

## Features

- Secure issuance of digital prescriptions by authorized doctors
- Verification of prescription validity by pharmacies
- Prevention of duplicate prescription fills
- Complete audit trail of prescription history
- Expiration enforcement for prescriptions

## Smart Contract Functions

- `add-doctor`: Register an authorized doctor in the system
- `add-pharmacy`: Register an authorized pharmacy
- `issue-prescription`: Create a new digital prescription
- `fill-prescription`: Mark a prescription as filled by a pharmacy
- `verify-prescription`: Check the details and status of a prescription
- `is-valid-unfilled`: Verify if a prescription is valid and has not been filled

## Getting Started

1. Clone this repository
2. Install Clarinet: `npm install -g @stacks/clarinet`
3. Run tests: `clarinet test`

## Security Considerations

- Only authorized doctors can issue prescriptions
- Only authorized pharmacies can fill prescriptions
- Prescriptions cannot be filled more than once
- Expired prescriptions cannot be filled
