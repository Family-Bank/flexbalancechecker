using Dapper;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess;
using System.ComponentModel.DataAnnotations;

namespace Flex_Balance_Fetcher.Controllers
{
    [ApiController]
    public class FlexBalanceController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger _logger;
        public FlexBalanceController(IConfiguration configuration)
        {
            _configuration = configuration;

        }

        [HttpGet]
        [Route("/GetBalance")]
        public async Task<IActionResult> GetBalance(string AccountNumber)
        {
            decimal balance;
            if (string.IsNullOrEmpty(AccountNumber))
            {
                return BadRequest("Account Number is required");
            }
            var balanceQuery = _configuration["Queries:GetBalanceQuery"];
            balanceQuery = balanceQuery.Replace("{AccountNumber}", AccountNumber);

            try
            {
                using (OracleConnection sqlConnection = new OracleConnection(_configuration.GetConnectionString("FlexcubeConnection")))
                {
                    await sqlConnection.OpenAsync();
                    var result = await sqlConnection.QueryAsync<decimal>(balanceQuery);
                    // With this line:
                    if (!result.Any())
                    {
                        return BadRequest("Account does not exist");
                    }
                    balance = result.FirstOrDefault();
                }
                return Ok(balance);
            }
            catch (Exception ex)
            {
                _logger.LogError("GetBalance Exception: {Message}", ex.Message);

                if (ex.InnerException != null)
                {
                    _logger.LogError("GetBalance InnerException: {InnerException}", ex.InnerException.Message);
                }
                return StatusCode(StatusCodes.Status500InternalServerError, "An error occurred while processing your request.");
            }
        }  
    }
}
