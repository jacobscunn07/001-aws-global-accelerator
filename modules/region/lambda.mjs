export const handler = async (event) => {
	const response = {
		statusCode: 200,
		headers: {
			"Content-Type": "application/json",
		},
		body: JSON.stringify({ message: `hello from ${process.env.AWS_REGION}` }),
		};
		
	return response;
};

