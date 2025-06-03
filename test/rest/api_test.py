import http.client
import os
import unittest
from urllib.request import urlopen

import pytest

BASE_URL = os.environ.get("BASE_URL")
DEFAULT_TIMEOUT = 2  # in secs


@pytest.mark.api
class TestApi(unittest.TestCase):
    def setUp(self):
        self.assertIsNotNone(BASE_URL, "URL no configurada")
        self.assertTrue(len(BASE_URL) > 8, "URL no configurada")

    def test_api_add(self):
        url = f"{BASE_URL}/calc/add/2/2"
        response = urlopen(url, timeout=DEFAULT_TIMEOUT)
        self.assertEqual(
            response.status, http.client.OK, f"Error en la petición API a {url}"
        )

    def test_api_multiply(self):
        url = f"{BASE_URL}/calc/multiply/3/4"
        response = urlopen(url, timeout=DEFAULT_TIMEOUT)
        self.assertEqual(response.status, http.client.OK)
        self.assertEqual(response.read().decode().strip(), "12")

    def test_api_divide(self):
        url = f"{BASE_URL}/calc/divide/8/2"
        response = urlopen(url, timeout=DEFAULT_TIMEOUT)
        self.assertEqual(response.status, http.client.OK)
        self.assertEqual(response.read().decode().strip(), "4.0")

    def test_api_divide_by_zero(self):
        url = f"{BASE_URL}/calc/divide/1/0"
        try:
            urlopen(url, timeout=DEFAULT_TIMEOUT)
            self.fail("Debería haber lanzado HTTPError")
        except Exception as e:
            self.assertIn("HTTP Error 400", str(e))

    def test_api_power(self):
        url = f"{BASE_URL}/calc/power/2/3"
        response = urlopen(url, timeout=DEFAULT_TIMEOUT)
        self.assertEqual(response.status, http.client.OK)
        self.assertEqual(response.read().decode().strip(), "8")

    def test_api_sqrt(self):
        url = f"{BASE_URL}/calc/sqrt/16"
        response = urlopen(url, timeout=DEFAULT_TIMEOUT)
        self.assertEqual(response.status, http.client.OK)
        self.assertEqual(response.read().decode().strip(), "4.0")

    def test_api_sqrt_negative(self):
        url = f"{BASE_URL}/calc/sqrt/-4"
        try:
            urlopen(url, timeout=DEFAULT_TIMEOUT)
            self.fail("Debería haber lanzado HTTPError")
        except Exception as e:
            self.assertIn("HTTP Error 400", str(e))

    def test_api_log10(self):
        url = f"{BASE_URL}/calc/log10/1000"
        response = urlopen(url, timeout=DEFAULT_TIMEOUT)
        self.assertEqual(response.status, http.client.OK)
        self.assertAlmostEqual(float(response.read().decode().strip()), 3.0, places=6)

    def test_api_log10_nonpositive(self):
        for val in [0, -10]:
            url = f"{BASE_URL}/calc/log10/{val}"
            try:
                urlopen(url, timeout=DEFAULT_TIMEOUT)
                self.fail("Debería haber lanzado HTTPError")
            except Exception as e:
                self.assertIn("HTTP Error 400", str(e))
